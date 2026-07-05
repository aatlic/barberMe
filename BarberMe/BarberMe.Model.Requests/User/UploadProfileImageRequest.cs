using Microsoft.AspNetCore.Http;
using System.ComponentModel.DataAnnotations;

namespace BarberMe.Model.Requests.User
{
    public class UploadProfileImageRequest
    {
        [Required(ErrorMessage = "Please select an image.")]
        public IFormFile File { get; set; } = null!;
    }
}