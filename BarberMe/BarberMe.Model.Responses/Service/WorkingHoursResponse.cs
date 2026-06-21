namespace BarberMe.Model.Responses.Service
{
    public class WorkingHoursResponse : BaseResponse
    {
        public int BarberId { get; set; }
        public string BarberFullName { get; set; } = null!;

        public int DayOfWeek { get; set; }
        public string DayName { get; set; } = null!;

        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }

        public bool IsWorking { get; set; }
    }
}
