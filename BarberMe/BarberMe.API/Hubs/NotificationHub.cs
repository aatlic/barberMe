using BarberMe.Model.Constants;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace BarberMe.API.Hubs
{
    [Authorize(Roles = $"{Roles.Admin},{Roles.Barber},{Roles.Client}")]
    public class NotificationHub : Hub
    {
        private readonly ILogger<NotificationHub> _logger;

        public NotificationHub(ILogger<NotificationHub> logger)
        {
            _logger = logger;
        }

        public override async Task OnConnectedAsync()
        {
            _logger.LogInformation(
                "SignalR connected. UserId: {UserId}, ConnectionId: {ConnectionId}",
                Context.UserIdentifier,
                Context.ConnectionId);

            await base.OnConnectedAsync();
        }

        public override async Task OnDisconnectedAsync(Exception? exception)
        {
            _logger.LogInformation(
                "SignalR disconnected. UserId: {UserId}, ConnectionId: {ConnectionId}",
                Context.UserIdentifier,
                Context.ConnectionId);

            await base.OnDisconnectedAsync(exception);
        }
    }
}