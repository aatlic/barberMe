using System.ComponentModel.DataAnnotations;

namespace BarberMe.Model.Requests.Appointment
{
    public class AppointmentInsertRequest
    {
        [Range(1, int.MaxValue, ErrorMessage = "Client is required.")]
        public int ClientId { get; set; }

        [Range(1, int.MaxValue, ErrorMessage = "Barber service is required.")]
        public int BarberServiceId { get; set; }

        [Required(ErrorMessage = "Appointment date and time is required.")]
        public DateTime StartDateTime { get; set; }

        public bool ReminderEnabled { get; set; }
    }
}