using BarberMe.Database.Context;
using BarberMe.Model.Enum;
using BarberMe.Model.Messaging;
using Microsoft.EntityFrameworkCore;

namespace BarberMe.Worker.Services
{
    public class AppointmentReminderWorker : BackgroundService
    {
        private readonly IServiceScopeFactory _scopeFactory;
        private readonly ILogger<AppointmentReminderWorker> _logger;

        public AppointmentReminderWorker(
            IServiceScopeFactory scopeFactory,
            ILogger<AppointmentReminderWorker> logger)
        {
            _scopeFactory = scopeFactory;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(
            CancellationToken stoppingToken)
        {
            _logger.LogInformation(
                "Appointment reminder worker started.");

            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    await ProcessRemindersAsync(stoppingToken);
                }
                catch (Exception exception)
                {
                    _logger.LogError(
                        exception,
                        "An error occurred while processing appointment reminders.");
                }

                await Task.Delay(
                    TimeSpan.FromMinutes(5),
                    stoppingToken);
            }
        }

        private async Task ProcessRemindersAsync(
            CancellationToken cancellationToken)
        {
            using var scope = _scopeFactory.CreateScope();

            var context =
                scope.ServiceProvider
                    .GetRequiredService<BarberMeDbContext>();

            var notificationProcessor =
                scope.ServiceProvider
                    .GetRequiredService<INotificationProcessor>();

            var now = DateTime.UtcNow;

            await Process24HourRemindersAsync(
                context,
                notificationProcessor,
                now,
                cancellationToken);

            await Process1HourRemindersAsync(
                context,
                notificationProcessor,
                now,
                cancellationToken);
        }

        private async Task Process24HourRemindersAsync(
            BarberMeDbContext context,
            INotificationProcessor notificationProcessor,
            DateTime now,
            CancellationToken cancellationToken)
        {
            var appointments = await context.Appointments
                .Include(x => x.BarberService)
                    .ThenInclude(x => x.Service)
                .Where(x =>
                    x.ReminderEnabled &&
                    x.Reminder24hSentAt == null &&
                    x.AppointmentStatusId != (int)AppointmentStatusType.Cancelled &&
                    x.AppointmentStatusId != (int)AppointmentStatusType.Completed &&
                    x.StartDateTime > now.AddHours(1) &&
                    x.StartDateTime <= now.AddHours(24))
                .ToListAsync(cancellationToken);

            foreach (var appointment in appointments)
            {
                await notificationProcessor.ProcessAsync(
                    new NotificationMessage
                    {
                        UserId = appointment.ClientId,
                        NotificationTypeId = NotificationTypeEnum.Reminder,
                        Title = "Appointment reminder",
                        Text =
                            $"Reminder: you have an appointment on " +
                            $"{appointment.StartDateTime:dd.MM.yyyy HH:mm}.",
                        EventType = "AppointmentReminder24h",
                        CreatedAt = DateTime.UtcNow
                    });

                appointment.Reminder24hSentAt = DateTime.UtcNow;
            }

            await context.SaveChangesAsync(cancellationToken);
        }

        private async Task Process1HourRemindersAsync(
            BarberMeDbContext context,
            INotificationProcessor notificationProcessor,
            DateTime now,
            CancellationToken cancellationToken)
        {
            var appointments = await context.Appointments
                .Include(x => x.BarberService)
                    .ThenInclude(x => x.Service)
                .Where(x =>
                    x.ReminderEnabled &&
                    x.Reminder1hSentAt == null &&
                    x.AppointmentStatusId !=
                        (int)AppointmentStatusType.Cancelled &&
                    x.AppointmentStatusId !=
                        (int)AppointmentStatusType.Completed &&
                    x.StartDateTime > now &&
                    x.StartDateTime <= now.AddHours(1))
                .ToListAsync(cancellationToken);

            foreach (var appointment in appointments)
            {
                await notificationProcessor.ProcessAsync(
                    new NotificationMessage
                    {
                        UserId = appointment.ClientId,
                        NotificationTypeId =
                            NotificationTypeEnum.Reminder,

                        Title = "Appointment reminder",

                        Text =
                            $"Your appointment starts in less than one hour, " +
                            $"at {appointment.StartDateTime:dd.MM.yyyy HH:mm}.",

                        EventType = "AppointmentReminder1h",
                        CreatedAt = DateTime.UtcNow
                    });

                appointment.Reminder1hSentAt = DateTime.UtcNow;
            }

            await context.SaveChangesAsync(cancellationToken);
        }
    }
}