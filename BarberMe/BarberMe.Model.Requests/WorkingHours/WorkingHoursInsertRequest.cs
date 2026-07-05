using System.ComponentModel.DataAnnotations;

namespace BarberMe.Model.Requests.WorkingHours
{
    public class WorkingHoursInsertRequest
    {
        [Range(1, int.MaxValue, ErrorMessage = "Barber is required.")]
        public int BarberId { get; set; }

        [Range(0, 6, ErrorMessage = "Day of week must be between 0 (Sunday) and 6 (Saturday).")]
        public int DayOfWeek { get; set; }

        [Required(ErrorMessage = "Start time is required.")]
        public TimeSpan StartTime { get; set; }

        [Required(ErrorMessage = "End time is required.")]
        public TimeSpan EndTime { get; set; }

        public bool IsWorking { get; set; }
    }
}