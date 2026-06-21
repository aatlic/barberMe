namespace BarberMe.Database.Models
{
    public class NotificationType
    {
        public int NotificationTypeId { get; set; }
        public string Name { get; set; } = string.Empty;

        public ICollection<Notification> Notifications { get; set; } = new List<Notification>();
    }
}
