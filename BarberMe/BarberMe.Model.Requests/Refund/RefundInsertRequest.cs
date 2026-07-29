using System.ComponentModel.DataAnnotations;

namespace BarberMe.Model.Requests.Refund
{
    public class RefundInsertRequest
    {

        [StringLength(500, ErrorMessage = "Reason must not exceed 500 characters.")]
        public string? Reason { get; set; }
    }
}