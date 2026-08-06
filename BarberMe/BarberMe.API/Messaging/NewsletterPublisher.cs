using System.Text;
using System.Text.Json;
using BarberMe.Model.Messaging;
using BarberMe.Services.Interfaces;
using Microsoft.Extensions.Options;
using RabbitMQ.Client;

namespace BarberMe.Services
{
    public class NewsletterPublisher : INewsletterPublisher
    {
        private readonly RabbitMQSettings _settings;
        private readonly ILogger<NewsletterPublisher> _logger;

        public NewsletterPublisher(
            IOptions<RabbitMQSettings> settings,
            ILogger<NewsletterPublisher> logger)
        {
            _settings = settings.Value;
            _logger = logger;
        }

        public async Task PublishAsync(
            NewsletterMessage message,
            CancellationToken cancellationToken = default)
        {
            var factory = new ConnectionFactory
            {
                HostName = _settings.HostName,
                Port = _settings.Port,
                UserName = _settings.UserName,
                Password = _settings.Password
            };

            await using var connection =
                await factory.CreateConnectionAsync(cancellationToken);

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

            await channel.BasicPublishAsync(
                exchange: string.Empty,
                routingKey: _settings.NewsletterQueueName,
                mandatory: false,
                body: body,
                cancellationToken: cancellationToken);

            _logger.LogInformation(
                "Newsletter event {EventType} published to queue {QueueName}.",
                message.EventType,
                _settings.NewsletterQueueName);
        }
    }
}