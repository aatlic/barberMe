using System.ComponentModel.DataAnnotations;

namespace BarberMe.Model.Requests.Notification
{
    public class NotificationInsertRequest
    {
        [Range(1, int.MaxValue, ErrorMessage = "User is required.")]
        public int UserId { get; set; }

        [Required(ErrorMessage = "Title is required.")]
        [StringLength(100, MinimumLength = 3, ErrorMessage = "Title must be between 3 and 100 characters.")]
        public string Title { get; set; } = null!;

        [Required(ErrorMessage = "Notification text is required.")]
        [StringLength(1000, MinimumLength = 5, ErrorMessage = "Notification text must be between 5 and 1000 characters.")]
        public string Text { get; set; } = null!;

        [Range(1, int.MaxValue, ErrorMessage = "Notification type is required.")]
        public int NotificationTypeId { get; set; }
    }
}