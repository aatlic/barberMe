using System.ComponentModel.DataAnnotations;

namespace BarberMe.Model.Requests.Refund
{
    public class RefundInsertRequest
    {
        [Range(1, int.MaxValue, ErrorMessage = "Payment is required.")]
        public int PaymentId { get; set; }

        [Range(typeof(decimal), "0.01", "100000", ErrorMessage = "Refund amount must be greater than 0.")]
        public decimal Amount { get; set; }

        [StringLength(500, ErrorMessage = "Reason must not exceed 500 characters.")]
        public string? Reason { get; set; }
    }
}