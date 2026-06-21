namespace BarberMe.Database.Models
{
    public class AppointmentStatus
    {
        public int AppointmentStatusId { get; set; }
        public string Name { get; set; } = string.Empty;

        public ICollection<Appointment> Appointments { get; set; } = new List<Appointment>();
    }
}
