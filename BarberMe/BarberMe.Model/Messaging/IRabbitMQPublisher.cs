namespace BarberMe.Model.Messaging
{
    public interface IRabbitMQPublisher
    {
        Task PublishAsync(
            string message,
            CancellationToken cancellationToken = default);

        Task PublishAsync<TMessage>(
            TMessage message,
            CancellationToken cancellationToken = default);
    }
}