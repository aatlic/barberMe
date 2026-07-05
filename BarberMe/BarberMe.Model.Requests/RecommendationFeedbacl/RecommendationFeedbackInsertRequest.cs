using System.ComponentModel.DataAnnotations;

namespace BarberMe.Model.Requests.RecommendationFeedback
{
    public class RecommendationFeedbackInsertRequest
    {
        [Range(1, 5, ErrorMessage = "Rating must be between 1 and 5.")]
        public int Rating { get; set; }

        [StringLength(500, ErrorMessage = "Comment must not exceed 500 characters.")]
        public string? Comment { get; set; }
    }
}