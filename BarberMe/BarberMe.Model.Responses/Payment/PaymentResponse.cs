using BarberMe.Model.Enum;

namespace BarberMe.Model.Responses.Payment
{
    public class PaymentResponse : BaseResponse
    {
        public int AppointmentId { get; set; }

        public decimal Amount { get; set; }

        public PaymentStatusType Status { get; set; }

        public DateTime CreatedAt { get; set; }
        public DateTime? PaidAt { get; set; }
    }
}
