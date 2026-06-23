namespace BarberMe.Model.Requests.WorkingHours
{
    public class WorkingHoursInsertRequest
    {
        public int BarberId { get; set; }

        public int DayOfWeek { get; set; }

        public TimeSpan StartTime { get; set; }

        public TimeSpan EndTime { get; set; }

        public bool IsWorking { get; set; }
    }
}
