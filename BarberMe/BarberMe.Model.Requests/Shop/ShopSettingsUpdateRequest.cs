using System.ComponentModel.DataAnnotations;

namespace BarberMe.Model.Requests.ShopSettings
{
    public class ShopSettingsUpdateRequest
    {
        [Required]
        [StringLength(100)]
        public string Name { get; set; } = null!;

        [Required]
        [StringLength(200)]
        public string Address { get; set; } = null!;

        [Required]
        [StringLength(30)]
        public string PhoneNumber { get; set; } = null!;

        [Required]
        [EmailAddress]
        [StringLength(100)]
        public string Email { get; set; } = null!;

        [StringLength(500)]
        public string? Description { get; set; }
    }
}