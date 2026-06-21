namespace BarberMe.Database.Models
{
    public class Review
    {
        public int ReviewId { get; set; }

        public int AppointmentId { get; set; }
        public Appointment Appointment { get; set; } = null!;

        public int ClientId { get; set; }
        public User Client { get; set; } = null!;

        public int BarberId { get; set; }
        public User Barber { get; set; } = null!;

        public int Rating { get; set; }
        public string? Comment { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
