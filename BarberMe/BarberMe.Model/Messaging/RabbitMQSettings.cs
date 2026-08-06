namespace BarberMe.Model.Messaging
{
    public class RabbitMQSettings
    {
        public string HostName { get; set; } = string.Empty;
        public int Port { get; set; }
        public string UserName { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string NotificationQueueName { get; set; } = string.Empty;

        public string NewsletterQueueName { get; set; } = string.Empty;
    }
}