using System.ComponentModel.DataAnnotations;

namespace BarberMe.Model.Requests.WorkingHours
{
    public class WorkingHoursUpdateRequest
    {
        [Required(ErrorMessage = "Start time is required.")]
        public TimeSpan StartTime { get; set; }

        [Required(ErrorMessage = "End time is required.")]
        public TimeSpan EndTime { get; set; }

        public bool IsWorking { get; set; }
    }
}