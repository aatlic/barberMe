using System.ComponentModel.DataAnnotations;

namespace BarberMe.Model.Requests.Appointment
{
    public class CancelAppointmentRequest
    {
        [Required(ErrorMessage = "Cancellation reason is required.")]
        [StringLength(500, ErrorMessage = "Cancellation reason must not exceed 500 characters.")]
        public string? CancellationReason { get; set; } = null;
    }
}