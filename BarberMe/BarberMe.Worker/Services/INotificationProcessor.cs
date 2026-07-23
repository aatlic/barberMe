using BarberMe.Model.Messaging;

namespace BarberMe.Worker.Services
{
    public interface INotificationProcessor
    {
        Task ProcessAsync(
            NotificationMessage message,
            CancellationToken cancellationToken = default);
    }
}