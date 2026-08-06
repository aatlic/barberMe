using BarberMe.API.Messaging;
using BarberMe.Model.Messaging;
using BarberMe.Services.Interfaces;
using Microsoft.Extensions.Options;
using RabbitMQ.Client;
using System.Text;
using System.Text.Json;

namespace BarberMe.Services
{
    public class PasswordResetEmailPublisher
        : IPasswordResetEmailPublisher
    {
        private readonly RabbitMQSettings _settings;
        private readonly RabbitMQConnection _rabbitMQConnection;
        private readonly ILogger<PasswordResetEmailPublisher> _logger;

        public PasswordResetEmailPublisher(
            IOptions<RabbitMQSettings> settings,
            RabbitMQConnection rabbitMQConnection,
            ILogger<PasswordResetEmailPublisher> logger)
        {
            _settings = settings.Value;
            _rabbitMQConnection = rabbitMQConnection;
            _logger = logger;
        }

        public async Task PublishAsync(
            PasswordResetEmailMessage message,
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
                    queue: _settings.PasswordResetQueueName,
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
                    routingKey: _settings.PasswordResetQueueName,
                    mandatory: true,
                    basicProperties: properties,
                    body: body,
                    cancellationToken: cancellationToken);

                _logger.LogInformation(
                    "Password reset email queued for {Email}.",
                    message.RecipientEmail);
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
                    "Failed to queue password reset email for {Email}.",
                    message.RecipientEmail);

                throw;
            }
        }
    }
}