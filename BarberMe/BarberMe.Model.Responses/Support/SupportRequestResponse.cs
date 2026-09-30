using BarberMe.Model.Enum;

namespace BarberMe.Model.Responses.Support
{
    public class SupportRequestResponse : BaseResponse
    {
        public int? UserId { get; set; }

        public string FullName { get; set; } = null!;

        public string Email { get; set; } = null!;

        public string Subject { get; set; } = null!;

        public string Message { get; set; } = null!;

        public SupportRequestStatus Status { get; set; }

        public DateTime CreatedAt { get; set; }
    }
}