using BarberMe.Model.Enum;

namespace BarberMe.Database.Models
{
    public class SupportRequest
    {
        public int SupportRequestId { get; set; }

        public int? UserId { get; set; }
        public User? User { get; set; }

        public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;

        public string Subject { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;

        public SupportRequestStatus Status { get; set; } = SupportRequestStatus.Open;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
