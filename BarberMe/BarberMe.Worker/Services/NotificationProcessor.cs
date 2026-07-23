using BarberMe.Database.Context;
using BarberMe.Database.Models;
using BarberMe.Model.Messaging;
using Microsoft.EntityFrameworkCore;

namespace BarberMe.Worker.Services
{
    public class NotificationProcessor : INotificationProcessor
    {
        private readonly BarberMeDbContext _context;
        private readonly ILogger<NotificationProcessor> _logger;

        public NotificationProcessor(
            BarberMeDbContext context,
            ILogger<NotificationProcessor> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task ProcessAsync(
            NotificationMessage message,
            CancellationToken cancellationToken = default)
        {
            ArgumentNullException.ThrowIfNull(message);

            var userExists = await _context.Users
                .AnyAsync(
                    x => x.UserId == message.UserId,
                    cancellationToken);

            if (!userExists)
            {
                throw new InvalidOperationException(
                    $"User with ID {message.UserId} does not exist.");
            }

            var notificationTypeExists =
                await _context.NotificationTypes
                    .AnyAsync(
                        x => x.NotificationTypeId ==
                             (int)message.NotificationTypeId,
                        cancellationToken);

            if (!notificationTypeExists)
            {
                throw new InvalidOperationException(
                    $"Notification type with ID " +
                    $"{message.NotificationTypeId} does not exist.");
            }

            var notification = new Notification
            {
                UserId = message.UserId,
                NotificationTypeId = (int)message.NotificationTypeId,
                Title = message.Title,
                Text = message.Text,
                IsRead = false,
                CreatedAt = message.CreatedAt,
                ReadAt = null
            };

            _context.Notifications.Add(notification);

            await _context.SaveChangesAsync(cancellationToken);

            _logger.LogInformation(
                "Notification {NotificationId} created for user {UserId}.",
                notification.NotificationId,
                notification.UserId);
        }
    }
}