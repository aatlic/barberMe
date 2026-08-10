namespace BarberMe.Database.Models
{
    public class ShopWorkingHours
    {
        public int ShopWorkingHoursId { get; set; }

        public int DayOfWeek { get; set; }

        public TimeSpan StartTime { get; set; }

        public TimeSpan EndTime { get; set; }

        public bool IsWorking { get; set; }
    }
}
