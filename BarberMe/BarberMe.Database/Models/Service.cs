namespace BarberMe.Database.Models
{
    public class Service
    {
        public int ServiceId { get; set; }

        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string? ImageUrl { get; set; }

        public decimal DefaultPrice { get; set; }
        public int DefaultDurationMinutes { get; set; }


        public bool IsActive { get; set; } = true;

        public ICollection<BarberService> BarberServices { get; set; } = new List<BarberService>();
    }
}
