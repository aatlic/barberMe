namespace BarberMe.Model.Requests.Notification
{
    public class NotificationInsertRequest
    {
        public int UserId { get; set; }

        public string Title { get; set; } = null!;

        public string Text { get; set; } = null!;

        public int NotificationTypeId { get; set; }
    }
}
