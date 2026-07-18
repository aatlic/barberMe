using System.ComponentModel.DataAnnotations;

namespace BarberMe.Model.Requests.User
{
    public class ForgotPasswordRequest
    {
        [Required(ErrorMessage = "Email is required.")]
        [EmailAddress(ErrorMessage = "Please enter a valid email address.")]
        [StringLength(
            100,
            ErrorMessage = "Email must not exceed 100 characters.")]
        public string Email { get; set; } = null!;
    }
}