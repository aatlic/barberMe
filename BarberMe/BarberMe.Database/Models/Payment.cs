namespace BarberMe.Database.Models
{
    public class Payment
    {
        public int PaymentId { get; set; }

        public int AppointmentId { get; set; }
        public Appointment Appointment { get; set; } = null!;

        public decimal Amount { get; set; }

        public string? StripePaymentIntentId { get; set; }

        public int PaymentStatusId { get; set; }
        public PaymentStatus PaymentStatus { get; set; } = null!;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? PaidAt { get; set; }

        public ICollection<Refund> Refunds { get; set; } = new List<Refund>();
    }
}
