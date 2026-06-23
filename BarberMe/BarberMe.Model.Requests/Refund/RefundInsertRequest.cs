namespace BarberMe.Model.Requests.Refund
{
    public class RefundInsertRequest
    {
        public int PaymentId { get; set; }

        public decimal Amount { get; set; }

        public string? Reason { get; set; }
    }
}
