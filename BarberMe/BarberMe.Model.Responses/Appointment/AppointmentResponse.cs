using BarberMe.Model.Enum;

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

        public AppointmentStatusType Status { get; set; }

        public bool IsPaid { get; set; }
        public bool ReminderEnabled { get; set; }

        public string? CancellationReason { get; set; }

        public bool HasReview { get; set; }
    }
}
