using Microsoft.AspNetCore.Http;
using System.ComponentModel.DataAnnotations;

namespace BarberMe.Model.Requests.Notification
{
    public class NewsUpdateRequest
    {
        [Required(ErrorMessage = "Title is required.")]
        [StringLength(100, MinimumLength = 3, ErrorMessage = "Title must be between 3 and 100 characters.")]
        public string Title { get; set; } = null!;

        [Required(ErrorMessage = "Content is required.")]
        [StringLength(2000, MinimumLength = 10, ErrorMessage = "Content must be between 10 and 2000 characters.")]
        public string Content { get; set; } = null!;

        public IFormFile? Image { get; set; }

        public bool IsActive { get; set; }
    }
}