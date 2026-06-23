namespace BarberMe.Model.Requests.Appointment
{
    public class AppointmentUpdateRequest
    {
        public int AppointmentStatusId { get; set; }

        public string? CancellationReason { get; set; }
    }
}
