using BarberMe.Model.Messaging;
using BarberMe.Worker.Configuration;
using BarberMe.Worker.Services;
using Microsoft.Extensions.Options;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System.Text;
using System.Text.Json;

namespace BarberMe.Worker
{
    public class PasswordResetEmailWorker : BackgroundService
    {
        private readonly IServiceScopeFactory _scopeFactory;
        private readonly RabbitMQSettings _settings;
        private readonly ILogger<PasswordResetEmailWorker> _logger;

        public PasswordResetEmailWorker(
            IServiceScopeFactory scopeFactory,
            IOptions<RabbitMQSettings> settings,
            ILogger<PasswordResetEmailWorker> logger)
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
                queue: _settings.PasswordResetQueueName,
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
                        JsonSerializer.Deserialize<PasswordResetEmailMessage>(
                            json);

                    if (message == null)
                    {
                        throw new InvalidOperationException(
                            "Password reset email message is invalid.");
                    }

                    using var scope =
                        _scopeFactory.CreateScope();

                    var emailSender =
                        scope.ServiceProvider
                            .GetRequiredService<IEmailSender>();

                    var body =
                        $"Poštovani/Poštovana {message.FirstName},\n\n" +
                        "Zaprimili smo zahtjev za resetovanje vaše lozinke.\n\n" +
                        $"Privremena lozinka: {message.TemporaryPassword}\n" +
                        $"Lozinka vrijedi do: {message.ExpiresAt:dd.MM.yyyy HH:mm} UTC.\n\n" +
                        "Nakon prijave bit ćete obavezni postaviti novu lozinku.\n\n" +
                        "Ako niste poslali ovaj zahtjev, obratite se podršci.\n\n" +
                        "Srdačan pozdrav,\nBarber Me";

                    await emailSender.SendAsync(
                        message.RecipientEmail,
                        "Barber Me - Privremena lozinka",
                        body,
                        stoppingToken);

                    await channel.BasicAckAsync(
                        eventArgs.DeliveryTag,
                        false,
                        stoppingToken);

                    _logger.LogInformation(
                        "Password reset email sent to {RecipientEmail}.",
                        message.RecipientEmail);
                }
                catch (Exception exception)
                {
                    _logger.LogError(
                        exception,
                        "Password reset email processing failed.");

                    await channel.BasicNackAsync(
                        eventArgs.DeliveryTag,
                        false,
                        false,
                        stoppingToken);
                }
            };

            await channel.BasicConsumeAsync(
                queue: _settings.PasswordResetQueueName,
                autoAck: false,
                consumer: consumer,
                cancellationToken: stoppingToken);

            _logger.LogInformation(
                "Password reset email worker is listening on queue {QueueName}.",
                _settings.PasswordResetQueueName);

            await Task.Delay(
                Timeout.Infinite,
                stoppingToken);
        }
    }
}