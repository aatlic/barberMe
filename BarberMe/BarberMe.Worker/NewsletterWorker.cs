using BarberMe.Model.Messaging;
using BarberMe.Worker.Configuration;
using BarberMe.Worker.Helpers;
using BarberMe.Worker.Services;
using Microsoft.Extensions.Options;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System.Text;
using System.Text.Json;

namespace BarberMe.Worker
{
    public class NewsletterWorker : BackgroundService
    {
        private readonly IServiceScopeFactory _scopeFactory;
        private readonly RabbitMQSettings _settings;
        private readonly ILogger<NewsletterWorker> _logger;

        public NewsletterWorker(
            IServiceScopeFactory scopeFactory,
            IOptions<RabbitMQSettings> settings,
            ILogger<NewsletterWorker> logger)
        {
            _scopeFactory = scopeFactory;
            _settings = settings.Value;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(
            CancellationToken stoppingToken)
        {
            var factory = new ConnectionFactory
            {
                HostName = _settings.HostName,
                Port = _settings.Port,
                UserName = _settings.UserName,
                Password = _settings.Password
            };

            var connection =
                await factory.CreateConnectionAsync(stoppingToken);

            var channel =
                await connection.CreateChannelAsync(
                    cancellationToken: stoppingToken);

            await channel.QueueDeclareAsync(
                queue: _settings.NewsletterQueueName,
                durable: true,
                exclusive: false,
                autoDelete: false,
                arguments: null,
                cancellationToken: stoppingToken);

            var consumer =
                new AsyncEventingBasicConsumer(channel);

            consumer.ReceivedAsync += async (_, eventArgs) =>
            {
                try
                {
                    var json = Encoding.UTF8.GetString(
                        eventArgs.Body.ToArray());

                    var message =
                        JsonSerializer.Deserialize<NewsletterMessage>(json);

                    if (message != null)
                    {
                        await RabbitMqRetryHelper.ExecuteAsync(
                            async () =>
                            {
                                using var scope =
                                    _scopeFactory.CreateScope();

                                var processor =
                                    scope.ServiceProvider
                                        .GetRequiredService<INewsletterProcessor>();

                                await processor.ProcessAsync(
                                    message,
                                    stoppingToken);
                            },
                            _logger,
                            $"Newsletter processing for event {message.EventType}",
                            stoppingToken);
                    }

                    await channel.BasicAckAsync(
                        eventArgs.DeliveryTag,
                        false,
                        stoppingToken);
                }
                catch (Exception exception)
                {
                    _logger.LogError(
                        exception,
                        "Newsletter processing failed.");

                    await channel.BasicNackAsync(
                        eventArgs.DeliveryTag,
                        false,
                        false,
                        stoppingToken);
                }
            };

            await channel.BasicConsumeAsync(
                queue: _settings.NewsletterQueueName,
                autoAck: false,
                consumer: consumer,
                cancellationToken: stoppingToken);

            _logger.LogInformation(
                "Newsletter worker is listening on queue {QueueName}.",
                _settings.NewsletterQueueName);

            await Task.Delay(
                Timeout.Infinite,
                stoppingToken);
        }
    }
}