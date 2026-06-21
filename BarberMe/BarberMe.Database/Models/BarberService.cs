namespace BarberMe.Database.Models
{
    public class BarberService
    {
        public int BarberServiceId { get; set; }

        public int BarberId { get; set; }
        public User Barber { get; set; } = null!;

        public int ServiceId { get; set; }
        public Service Service { get; set; } = null!;

        public decimal Price { get; set; }
        public int DurationMinutes { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
