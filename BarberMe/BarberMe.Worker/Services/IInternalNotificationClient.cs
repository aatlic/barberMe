using BarberMe.Model.Messaging;

namespace BarberMe.Worker.Services
{
    public interface IInternalNotificationClient
    {
        Task SendAsync(
            NotificationMessage message,
            CancellationToken cancellationToken = default);
    }
}