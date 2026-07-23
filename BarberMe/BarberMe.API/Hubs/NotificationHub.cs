using BarberMe.Model.Constants;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace BarberMe.API.Hubs
{
    [Authorize(Roles = $"{Roles.Admin},{Roles.Barber},{Roles.Client}")]
    public class NotificationHub : Hub
    {
        public override async Task OnConnectedAsync()
        {
            Console.WriteLine(
                $"SignalR connected. UserId: {Context.UserIdentifier}, ConnectionId: {Context.ConnectionId}");

            await base.OnConnectedAsync();
        }

        public override async Task OnDisconnectedAsync(Exception? exception)
        {
            Console.WriteLine(
                $"SignalR disconnected. UserId: {Context.UserIdentifier}, ConnectionId: {Context.ConnectionId}");

            await base.OnDisconnectedAsync(exception);
        }
    }
}