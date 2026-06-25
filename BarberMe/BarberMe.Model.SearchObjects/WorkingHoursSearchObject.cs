namespace BarberMe.Model.SearchObjects
{
    public class WorkingHoursSearchObject : BaseSearchObject
    {
        public int? BarberId { get; set; }

        public DayOfWeek? Day { get; set; }
    }
}
