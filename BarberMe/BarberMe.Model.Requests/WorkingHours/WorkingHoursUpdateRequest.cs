namespace BarberMe.Model.Requests.WorkingHours
{
    public class WorkingHoursUpdateRequest
    {
        public TimeSpan StartTime { get; set; }

        public TimeSpan EndTime { get; set; }

        public bool IsWorking { get; set; }
    }
}
