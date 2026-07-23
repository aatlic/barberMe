using BarberMe.API.Hubs;
using BarberMe.Model.Messaging;
using Microsoft.AspNetCore.SignalR;

namespace BarberMe.API.SignalR
{
    public class NotificationHubService : INotificationHubService
    {
        private readonly IHubContext<NotificationHub> _hubContext;
        private readonly ILogger<NotificationHubService> _logger;

        public NotificationHubService(
            IHubContext<NotificationHub> hubContext,
            ILogger<NotificationHubService> logger)
        {
            _hubContext = hubContext;
            _logger = logger;
        }

        public async Task SendToUserAsync(NotificationMessage message)
        {
            await _hubContext.Clients
                .User(message.UserId.ToString())
                .SendAsync("ReceiveNotification", message);

            _logger.LogInformation(
                "SignalR notification sent to user {UserId}. EventType: {EventType}",
                message.UserId,
                message.EventType);
        }
    }
}