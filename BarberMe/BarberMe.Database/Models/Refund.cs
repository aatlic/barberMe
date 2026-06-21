namespace BarberMe.Database.Models
{
    public class Refund
    {
        public int RefundId { get; set; }

        public int PaymentId { get; set; }
        public Payment Payment { get; set; } = null!;

        public decimal Amount { get; set; }

        public string? StripeRefundId { get; set; }
        public string? Reason { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
