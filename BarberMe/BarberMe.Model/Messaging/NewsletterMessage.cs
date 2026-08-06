namespace BarberMe.Model.Messaging
{
    public class NewsletterMessage
    {
        public string Subject { get; set; } = string.Empty;

        public string Body { get; set; } = string.Empty;

        public string EventType { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}