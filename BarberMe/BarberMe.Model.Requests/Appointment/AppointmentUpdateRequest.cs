using System.ComponentModel.DataAnnotations;

namespace BarberMe.Model.Requests.Appointment
{
    public class AppointmentUpdateRequest
    {
        [Range(1, int.MaxValue, ErrorMessage = "Appointment status is required.")]
        public int AppointmentStatusId { get; set; }

        [StringLength(500, ErrorMessage = "Cancellation reason must not exceed 500 characters.")]
        public string? CancellationReason { get; set; }
    }
}