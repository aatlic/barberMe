using System.ComponentModel.DataAnnotations;

namespace BarberMe.Model.Requests.ShopWorkingHours
{
    public class ShopWorkingHoursUpdateRequest
    {
        [Range(0, 6)]
        public int DayOfWeek { get; set; }

        public TimeSpan StartTime { get; set; }

        public TimeSpan EndTime { get; set; }

        public bool IsWorking { get; set; }
    }
}