using System.ComponentModel.DataAnnotations;

namespace BarberMe.Model.Requests.BarberService
{
    public class BarberServiceUpdateRequest
    {
        [Range(typeof(decimal), "0.01", "10000", ErrorMessage = "Price must be greater than 0.")]
        public decimal Price { get; set; }

        [Range(1, 1000, ErrorMessage = "Duration must be between 1 and 1000 minutes.")]
        public int DurationMinutes { get; set; }
    }
}