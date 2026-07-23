using BarberMe.Model.Messaging;
using Microsoft.Extensions.Options;
using RabbitMQ.Client;
using System.Text;
using System.Text.Json;

namespace BarberMe.API.Messaging
{
    public class RabbitMQPublisher : IRabbitMQPublisher
    {
        private readonly RabbitMQConnection _rabbitMQConnection;
        private readonly RabbitMQSettings _settings;
        private readonly ILogger<RabbitMQPublisher> _logger;
        private readonly SemaphoreSlim _publishLock = new(1, 1);

        private IChannel? _channel;

        public RabbitMQPublisher(
            RabbitMQConnection rabbitMQConnection,
            IOptions<RabbitMQSettings> options,
            ILogger<RabbitMQPublisher> logger)
        {
            _rabbitMQConnection = rabbitMQConnection;
            _settings = options.Value;
            _logger = logger;
        }

        public async Task PublishAsync(
            string message,
            CancellationToken cancellationToken = default)
        {
            await _publishLock.WaitAsync(cancellationToken);

            try
            {
                await EnsureChannelAsync(cancellationToken);

                var body = Encoding.UTF8.GetBytes(message);

                var properties = new BasicProperties
                {
                    Persistent = true,
                    ContentType = "application/json"
                };

                await _channel!.BasicPublishAsync(
                    exchange: string.Empty,
                    routingKey: _settings.QueueName,
                    mandatory: true,
                    basicProperties: properties,
                    body: body,
                    cancellationToken: cancellationToken);

                _logger.LogInformation(
                    "Message published to RabbitMQ queue {QueueName}.",
                    _settings.QueueName);
            }
            catch (Exception exception)
            {
                _logger.LogError(
                    exception,
                    "Failed to publish message to RabbitMQ queue {QueueName}.",
                    _settings.QueueName);

                throw;
            }
            finally
            {
                _publishLock.Release();
            }
        }

        private async Task EnsureChannelAsync(
            CancellationToken cancellationToken)
        {
            if (_channel is { IsOpen: true })
            {
                return;
            }

            if (_channel is not null)
            {
                await _channel.DisposeAsync();
                _channel = null;
            }

            var connection =
                await _rabbitMQConnection.GetConnectionAsync(cancellationToken);

            _channel = await connection.CreateChannelAsync(
                cancellationToken: cancellationToken);

            await _channel.QueueDeclareAsync(
                queue: _settings.QueueName,
                durable: true,
                exclusive: false,
                autoDelete: false,
                arguments: null,
                cancellationToken: cancellationToken);
        }

        public async Task PublishAsync<TMessage>(
            TMessage message,
            CancellationToken cancellationToken = default)
        {
            ArgumentNullException.ThrowIfNull(message);

            var json = JsonSerializer.Serialize(message);

            await PublishAsync(json, cancellationToken);
        }
    }
}