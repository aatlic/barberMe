using BarberMe.Model.Messaging;

namespace BarberMe.Services.Interfaces
{
    public interface ISupportRequestEmailPublisher
    {
        Task PublishAsync(
            SupportRequestEmailMessage message,
            CancellationToken cancellationToken = default);
    }
}