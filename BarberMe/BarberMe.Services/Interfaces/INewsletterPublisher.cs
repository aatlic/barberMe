using BarberMe.Model.Messaging;

namespace BarberMe.Services.Interfaces
{
    public interface INewsletterPublisher
    {
        Task PublishAsync(
            NewsletterMessage message,
            CancellationToken cancellationToken = default);
    }
}