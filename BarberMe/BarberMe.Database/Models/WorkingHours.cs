namespace BarberMe.Database.Models
{
    public class WorkingHours
    {
        public int WorkingHoursId { get; set; }

        public int BarberId { get; set; }
        public User Barber { get; set; } = null!;

        public int DayOfWeek { get; set; }

        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }

        public bool IsWorking { get; set; } = true;
    }
}
