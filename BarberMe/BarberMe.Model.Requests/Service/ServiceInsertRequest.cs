using Microsoft.AspNetCore.Http;
using System.ComponentModel.DataAnnotations;

namespace BarberMe.Model.Requests.Service
{
    public class ServiceInsertRequest
    {
        [Required(ErrorMessage = "Service name is required.")]
        [StringLength(100, MinimumLength = 2, ErrorMessage = "Service name must be between 2 and 100 characters.")]
        public string Name { get; set; } = null!;

        [StringLength(500, ErrorMessage = "Description must not exceed 500 characters.")]
        public string? Description { get; set; }

        [Range(1, 1000, ErrorMessage = "Duration must be between 1 and 1000 minutes.")]
        public int DurationMinutes { get; set; }

        [Range(typeof(decimal), "0.01", "10000", ErrorMessage = "Price must be greater than 0.")]
        public decimal Price { get; set; }

        public IFormFile? Image { get; set; }

        public bool IsActive { get; set; }
    }
}