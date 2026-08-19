namespace BarberMe.Model.Responses.Appointment
{
    public class AppointmentResponse : BaseResponse
    {
        public int ClientId { get; set; }
        public string ClientFullName { get; set; } = null!;

        public int BarberId { get; set; }
        public string BarberFullName { get; set; } = null!;

        public int BarberServiceId { get; set; }

        public int ServiceId { get; set; }
        public string ServiceName { get; set; } = null!;

        public decimal Price { get; set; }
        public int DurationMinutes { get; set; }

        public DateTime StartDateTime { get; set; }
        public DateTime EndDateTime { get; set; }

        public string Status { get; set; } = null!;

        public bool IsPaid { get; set; }
        public bool ReminderEnabled { get; set; }

        public string? CancellationReason { get; set; }

        public bool HasReview { get; set; }
        public decimal BasePrice { get; set; }

        public decimal AppliedDiscountPercent { get; set; }

        public decimal AppliedPenaltyPercent { get; set; }

        public decimal FinalPrice { get; set; }
    }
}
