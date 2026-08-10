namespace BarberMe.Model.Responses
{
    public class ShopWorkingHoursResponse
    {
        public int Id { get; set; }

        public int DayOfWeek { get; set; }

        public TimeSpan StartTime { get; set; }

        public TimeSpan EndTime { get; set; }

        public bool IsWorking { get; set; }
    }
}