namespace BarberMe.Model.Responses.Payment
{
    public class RefundResponse : BaseResponse
    {
        public int PaymentId { get; set; }

        public decimal Amount { get; set; }

        public string? Reason { get; set; }

        public DateTime CreatedAt { get; set; }
    }
}
