namespace BarberMe.Model.Messaging
{
    public interface IRabbitMQPublisher
    {
        Task<bool> PublishAsync(
            string message,
            CancellationToken cancellationToken = default);

        Task<bool> PublishAsync<TMessage>(
            TMessage message,
            CancellationToken cancellationToken = default);
    }
}