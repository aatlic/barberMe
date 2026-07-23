using BarberMe.Model.Messaging;

namespace BarberMe.API.SignalR
{
    public interface INotificationHubService
    {
        Task SendToUserAsync(NotificationMessage message);
    }
}