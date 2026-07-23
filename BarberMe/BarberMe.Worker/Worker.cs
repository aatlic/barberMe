using System.Text;
using System.Text.Json;
using BarberMe.Model.Messaging;
using BarberMe.Worker.Services;
using Microsoft.Extensions.Options;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;

namespace BarberMe.Worker
{
    public class Worker : BackgroundService
    {
        private readonly ILogger<Worker> _logger;
        private readonly RabbitMQSettings _rabbitMQSettings;
        private readonly IServiceScopeFactory _serviceScopeFactory;

        private IConnection? _connection;
        private IChannel? _channel;

        public Worker(
            ILogger<Worker> logger,
            IOptions<RabbitMQSettings> rabbitMQOptions,
            IServiceScopeFactory serviceScopeFactory)
        {
            _logger = logger;
            _rabbitMQSettings = rabbitMQOptions.Value;
            _serviceScopeFactory = serviceScopeFactory;
        }

        protected override async Task ExecuteAsync(
            CancellationToken stoppingToken)
        {
            try
            {
                var factory = new ConnectionFactory
                {
                    HostName = _rabbitMQSettings.HostName,
                    Port = _rabbitMQSettings.Port,
                    UserName = _rabbitMQSettings.UserName,
                    Password = _rabbitMQSettings.Password,

                    AutomaticRecoveryEnabled = true,
                    NetworkRecoveryInterval = TimeSpan.FromSeconds(5)
                };

                _connection = await factory.CreateConnectionAsync(
                    clientProvidedName: "BarberMe.Worker",
                    cancellationToken: stoppingToken);

                _channel = await _connection.CreateChannelAsync(
                    cancellationToken: stoppingToken);

                await _channel.QueueDeclareAsync(
                    queue: _rabbitMQSettings.QueueName,
                    durable: true,
                    exclusive: false,
                    autoDelete: false,
                    arguments: null,
                    cancellationToken: stoppingToken);

                await _channel.BasicQosAsync(
                    prefetchSize: 0,
                    prefetchCount: 1,
                    global: false,
                    cancellationToken: stoppingToken);

                var consumer = new AsyncEventingBasicConsumer(_channel);

                consumer.ReceivedAsync += async (_, eventArgs) =>
                {
                    await ProcessMessageAsync(eventArgs);
                };

                await _channel.BasicConsumeAsync(
                    queue: _rabbitMQSettings.QueueName,
                    autoAck: false,
                    consumer: consumer,
                    cancellationToken: stoppingToken);

                _logger.LogInformation(
                    "Worker is listening to RabbitMQ queue {QueueName}.",
                    _rabbitMQSettings.QueueName);

                await Task.Delay(
                    Timeout.InfiniteTimeSpan,
                    stoppingToken);
            }
            catch (OperationCanceledException)
                when (stoppingToken.IsCancellationRequested)
            {
                _logger.LogInformation(
                    "RabbitMQ Worker is stopping.");
            }
            catch (Exception exception)
            {
                _logger.LogCritical(
                    exception,
                    "RabbitMQ Worker could not start.");
            }
            finally
            {
                if (_channel is not null)
                {
                    await _channel.DisposeAsync();
                    _channel = null;
                }

                if (_connection is not null)
                {
                    await _connection.DisposeAsync();
                    _connection = null;
                }
            }
        }

        private async Task ProcessMessageAsync(
            BasicDeliverEventArgs eventArgs)
        {
            if (_channel is null)
            {
                _logger.LogError(
                    "RabbitMQ channel is not available.");

                return;
            }

            var cancellationToken = eventArgs.CancellationToken;

            try
            {
                var messageBytes = eventArgs.Body.ToArray();
                var messageJson = Encoding.UTF8.GetString(messageBytes);

                _logger.LogInformation(
                    "RabbitMQ message received: {Message}",
                    messageJson);

                var message =
                    JsonSerializer.Deserialize<NotificationMessage>(
                        messageJson,
                        new JsonSerializerOptions
                        {
                            PropertyNameCaseInsensitive = true
                        });

                if (message is null)
                {
                    throw new JsonException(
                        "RabbitMQ message could not be deserialized.");
                }

                await using var scope =
                    _serviceScopeFactory.CreateAsyncScope();

                var notificationProcessor =
                    scope.ServiceProvider
                        .GetRequiredService<INotificationProcessor>();

                await notificationProcessor.ProcessAsync(
                    message,
                    cancellationToken);

                await _channel.BasicAckAsync(
                    deliveryTag: eventArgs.DeliveryTag,
                    multiple: false,
                    cancellationToken: cancellationToken);

                _logger.LogInformation(
                    "RabbitMQ message acknowledged for user {UserId} " +
                    "and event {EventType}.",
                    message.UserId,
                    message.EventType);
            }
            catch (JsonException exception)
            {
                _logger.LogError(
                    exception,
                    "RabbitMQ message contains invalid JSON.");

                await _channel.BasicNackAsync(
                    deliveryTag: eventArgs.DeliveryTag,
                    multiple: false,
                    requeue: false,
                    cancellationToken: cancellationToken);
            }
            catch (Exception exception)
            {
                _logger.LogError(
                    exception,
                    "An error occurred while processing " +
                    "a RabbitMQ message.");

                await _channel.BasicNackAsync(
                    deliveryTag: eventArgs.DeliveryTag,
                    multiple: false,
                    requeue: false,
                    cancellationToken: cancellationToken);
            }
        }
    }
}