using System.ComponentModel.DataAnnotations;

namespace BarberMe.Model.Requests.BarberService
{
    public class BarberServiceInsertRequest
    {
        [Range(1, int.MaxValue, ErrorMessage = "Barber is required.")]
        public int BarberId { get; set; }

        [Range(1, int.MaxValue, ErrorMessage = "Service is required.")]
        public int ServiceId { get; set; }

        [Range(typeof(decimal), "0.01", "10000", ErrorMessage = "Price must be greater than 0.")]
        public decimal Price { get; set; }

        [Range(1, 1000, ErrorMessage = "Duration must be between 1 and 1000 minutes.")]
        public int DurationMinutes { get; set; }
    }
}