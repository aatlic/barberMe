namespace BarberMe.Model.Responses.Appointment
{
    public class CalendarAvailabilityResponse
    {
        public DateOnly Date { get; set; }

        public bool IsWorkingDay { get; set; }

        public bool HasAvailableSlots { get; set; }
    }
}