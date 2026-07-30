using System.ComponentModel.DataAnnotations;

namespace BarberMe.Model.Requests.Appointment
{
    public class AppointmentRescheduleRequest
    {
        [Required]
        public DateTime StartDateTime { get; set; }
    }
}