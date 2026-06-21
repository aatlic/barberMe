namespace BarberMe.Database.Models
{
    public class Appointment
    {
        public int AppointmentId { get; set; }

        public int ClientId { get; set; }
        public User Client { get; set; } = null!;

        public int BarberId { get; set; }
        public User Barber { get; set; } = null!;

        public int BarberServiceId { get; set; }
        public BarberService BarberService { get; set; } = null!;

        public DateTime StartDateTime { get; set; }
        public DateTime EndDateTime { get; set; }

        public int AppointmentStatusId { get; set; }
        public AppointmentStatus AppointmentStatus { get; set; } = null!;

        public bool IsPaid { get; set; }
        public bool ReminderEnabled { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? ConfirmedAt { get; set; }
        public int? ConfirmedById { get; set; }
        public User? ConfirmedBy { get; set; }

        public DateTime? CancelledAt { get; set; }
        public int? CancelledById { get; set; }
        public User? CancelledBy { get; set; }

        public string? CancellationReason { get; set; }

        public DateTime? CompletedAt { get; set; }

        public Review? Review { get; set; }
        public Payment? Payment { get; set; }
    }
}
