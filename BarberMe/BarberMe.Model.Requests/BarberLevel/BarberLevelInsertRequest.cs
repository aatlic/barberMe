using System.ComponentModel.DataAnnotations;

namespace BarberMe.Model.Requests.BarberLevel
{
    public class BarberLevelInsertRequest
    {
        [Required(ErrorMessage = "Barber level name is required.")]
        [StringLength(50, MinimumLength = 2, ErrorMessage = "Barber level name must be between 2 and 50 characters.")]
        public string Name { get; set; } = null!;
    }
}