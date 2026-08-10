namespace BarberMe.Database.Models
{
    public class ShopSettings
    {
        public int ShopSettingsId { get; set; }

        public string Name { get; set; } = null!;

        public string Address { get; set; } = null!;

        public string PhoneNumber { get; set; } = null!;

        public string Email { get; set; } = null!;

        public string? Description { get; set; }
    }
}