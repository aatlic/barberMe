namespace BarberMe.Database.Models
{
    public class RecommendationFeedback
    {
        public int RecommendationFeedbackId { get; set; }

        public int RecommendationId { get; set; }
        public Recommendation Recommendation { get; set; } = null!;

        public int Rating { get; set; }
        public string? Comment { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
