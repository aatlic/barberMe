using System.ComponentModel.DataAnnotations;

namespace BarberMe.Model.Requests.Review
{
    public class ReviewInsertRequest
    {
        [Range(1, int.MaxValue, ErrorMessage = "Appointment is required.")]
        public int AppointmentId { get; set; }

        [Range(1, 5, ErrorMessage = "Rating must be between 1 and 5.")]
        public int Rating { get; set; }

        [StringLength(1000, ErrorMessage = "Comment must not exceed 1000 characters.")]
        public string? Comment { get; set; }
    }
}