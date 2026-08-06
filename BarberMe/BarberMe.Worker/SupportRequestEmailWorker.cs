using BarberMe.Database.Context;
using BarberMe.Model.Constants;
using BarberMe.Model.Messaging;
using BarberMe.Worker.Helpers;
using BarberMe.Worker.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System.Text;
using System.Text.Json;

namespace BarberMe.Worker
{
    public class SupportRequestEmailWorker : BackgroundService
    {
        private readonly IServiceScopeFactory _scopeFactory;
        private readonly RabbitMQSettings _settings;
        private readonly ILogger<SupportRequestEmailWorker> _logger;

        public SupportRequestEmailWorker(
            IServiceScopeFactory scopeFactory,
            IOptions<RabbitMQSettings> settings,
            ILogger<SupportRequestEmailWorker> logger)
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
                queue: _settings.SupportRequestQueueName,
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
                        JsonSerializer.Deserialize<SupportRequestEmailMessage>(
                            json);

                    if (message == null)
                    {
                        throw new InvalidOperationException(
                            "Support request email message is invalid.");
                    }

                    await RabbitMqRetryHelper.ExecuteAsync(
                        async () =>
                        {
                            using var scope =
                                _scopeFactory.CreateScope();

                            var context =
                                scope.ServiceProvider
                                    .GetRequiredService<BarberMeDbContext>();

                            var emailSender =
                                scope.ServiceProvider
                                    .GetRequiredService<IEmailSender>();

                            var adminEmails = await context.Users
                                .AsNoTracking()
                                .Where(x =>
                                    x.IsActive &&
                                    x.Role.Name == Roles.Admin)
                                .Select(x => x.Email)
                                .ToListAsync(stoppingToken);

                            if (adminEmails.Count == 0)
                            {
                                throw new InvalidOperationException(
                                    "No active administrator email addresses were found.");
                            }

                            var body =
                                "Zaprimljen je novi zahtjev za podršku.\n\n" +
                                $"ID zahtjeva: {message.SupportRequestId}\n" +
                                $"Ime i prezime: {message.FullName}\n" +
                                $"E-mail korisnika: {message.Email}\n" +
                                $"Predmet: {message.Subject}\n" +
                                $"Datum: {message.CreatedAt:dd.MM.yyyy HH:mm} UTC\n\n" +
                                $"Poruka:\n{message.Message}";

                            foreach (var adminEmail in adminEmails)
                            {
                                await emailSender.SendAsync(
                                    adminEmail,
                                    $"Barber Me podrška - {message.Subject}",
                                    body,
                                    stoppingToken);
                            }
                        },
                        _logger,
                        $"Support request email delivery for request {message.SupportRequestId}",
                        stoppingToken);

                    await channel.BasicAckAsync(
                        eventArgs.DeliveryTag,
                        false,
                        stoppingToken);

                    _logger.LogInformation(
                        "Support request {SupportRequestId} sent to administrators.",
                        message.SupportRequestId);
                }
                catch (Exception exception)
                {
                    _logger.LogError(
                        exception,
                        "Support request email processing failed.");

                    await channel.BasicNackAsync(
                        eventArgs.DeliveryTag,
                        false,
                        false,
                        stoppingToken);
                }
            };

            await channel.BasicConsumeAsync(
                queue: _settings.SupportRequestQueueName,
                autoAck: false,
                consumer: consumer,
                cancellationToken: stoppingToken);

            _logger.LogInformation(
                "Support request email worker is listening on queue {QueueName}.",
                _settings.SupportRequestQueueName);

            await Task.Delay(
                Timeout.Infinite,
                stoppingToken);
        }
    }
}