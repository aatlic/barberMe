using BarberMe.API.Messaging;
using BarberMe.Model.Messaging;
using BarberMe.Services.Interfaces;
using Microsoft.Extensions.Options;
using RabbitMQ.Client;
using System.Text;
using System.Text.Json;

namespace BarberMe.Services
{
    public class NewsletterPublisher : INewsletterPublisher
    {
        private readonly RabbitMQSettings _settings;
        private readonly RabbitMQConnection _rabbitMQConnection;
        private readonly ILogger<NewsletterPublisher> _logger;

        public NewsletterPublisher(
            IOptions<RabbitMQSettings> settings,
            RabbitMQConnection rabbitMQConnection,
            ILogger<NewsletterPublisher> logger)
        {
            _settings = settings.Value;
            _rabbitMQConnection = rabbitMQConnection;
            _logger = logger;
        }

        public async Task PublishAsync(
            NewsletterMessage message,
            CancellationToken cancellationToken = default)
        {
            ArgumentNullException.ThrowIfNull(message);

            try
            {
                var connection =
                    await _rabbitMQConnection.GetConnectionAsync(
                        cancellationToken);

                await using var channel =
                    await connection.CreateChannelAsync(
                        cancellationToken: cancellationToken);

                await channel.QueueDeclareAsync(
                    queue: _settings.NewsletterQueueName,
                    durable: true,
                    exclusive: false,
                    autoDelete: false,
                    arguments: null,
                    cancellationToken: cancellationToken);

                var body = Encoding.UTF8.GetBytes(
                    JsonSerializer.Serialize(message));

                var properties = new BasicProperties
                {
                    Persistent = true,
                    ContentType = "application/json"
                };

                await channel.BasicPublishAsync(
                    exchange: string.Empty,
                    routingKey: _settings.NewsletterQueueName,
                    mandatory: true,
                    basicProperties: properties,
                    body: body,
                    cancellationToken: cancellationToken);

                _logger.LogInformation(
                    "Newsletter event {EventType} published to queue {QueueName}.",
                    message.EventType,
                    _settings.NewsletterQueueName);
            }
            catch (OperationCanceledException)
                when (cancellationToken.IsCancellationRequested)
            {
                throw;
            }
            catch (Exception exception)
            {
                _logger.LogError(
                    exception,
                    "Failed to publish newsletter event {EventType} to queue {QueueName}. " +
                    "The main operation will remain successful.",
                    message.EventType,
                    _settings.NewsletterQueueName);
            }
        }
    }
}