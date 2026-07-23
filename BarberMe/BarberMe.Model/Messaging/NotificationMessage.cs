using BarberMe.Model.Enum;

namespace BarberMe.Model.Messaging
{
    public class NotificationMessage
    {
        public int UserId { get; set; }

        public NotificationTypeEnum NotificationTypeId { get; set; }

        public string Title { get; set; } = string.Empty;

        public string Text { get; set; } = string.Empty;

        public string EventType { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}