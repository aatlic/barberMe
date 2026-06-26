namespace BarberMe.Model.Requests.Appointment
{
    public class AppointmentInsertRequest
    {
        public int ClientId { get; set; }

        public int BarberServiceId { get; set; }

        public DateTime StartDateTime { get; set; }

        public bool ReminderEnabled { get; set; }
    }
}
