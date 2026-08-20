namespace BarberMe.Model.Responses.Notification
{
    public class NotificationResponse : BaseResponse
    {
        public int UserId { get; set; }

        public int NotificationTypeId { get; set; }

        public string NotificationTypeName { get; set; } = null!;

        public string Title { get; set; } = null!;

        public string Text { get; set; } = null!;

        public bool IsRead { get; set; }

        public DateTime CreatedAt { get; set; }

        public DateTime? ReadAt { get; set; }
    }
}