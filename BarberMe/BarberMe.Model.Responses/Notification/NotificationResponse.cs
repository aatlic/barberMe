using BarberMe.Model.Enum;

namespace BarberMe.Model.Responses.Notification
{
    public class NotificationResponse : BaseResponse
    {
        public int UserId { get; set; }

        public int ServiceId { get; set; }
        public string ServiceName { get; set; } = null!;

        public decimal Score { get; set; }

        public string Explanation { get; set; } = null!;

        public bool? WasAccepted { get; set; }

        public DateTime CreatedAt { get; set; }
        public DateTime? ReadAt { get; set; }
    }
}
