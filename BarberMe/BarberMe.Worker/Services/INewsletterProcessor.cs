using BarberMe.Model.Messaging;

namespace BarberMe.Worker.Services
{
    public interface INewsletterProcessor
    {
        Task ProcessAsync(
            NewsletterMessage message,
            CancellationToken cancellationToken = default);
    }
}