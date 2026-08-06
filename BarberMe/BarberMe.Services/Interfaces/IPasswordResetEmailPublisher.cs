using BarberMe.Model.Messaging;

namespace BarberMe.Services.Interfaces
{
    public interface IPasswordResetEmailPublisher
    {
        Task PublishAsync(
            PasswordResetEmailMessage message,
            CancellationToken cancellationToken = default);
    }
}