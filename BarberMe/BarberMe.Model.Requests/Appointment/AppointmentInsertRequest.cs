namespace BarberMe.Model.Requests.Appointment
{
    public class AppointmentInsertRequest
    {
        public int BarberServiceId { get; set; }

        public DateTime StartDateTime { get; set; }
    }
}
