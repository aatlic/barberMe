namespace BarberMe.Database.Models
{
    public class Notification
    {
        public int NotificationId { get; set; }

        public int UserId { get; set; }
        public User User { get; set; } = null!;

        public int NotificationTypeId { get; set; }
        public NotificationType NotificationType { get; set; } = null!;

        public string Title { get; set; } = string.Empty;
        public string Text { get; set; } = string.Empty;

        public bool IsRead { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? ReadAt { get; set; }
    }
}
