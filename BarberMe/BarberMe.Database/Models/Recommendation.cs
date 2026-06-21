namespace BarberMe.Database.Models
{
    public class Recommendation
    {
        public int RecommendationId { get; set; }

        public int UserId { get; set; }
        public User User { get; set; } = null!;

        public int ServiceId { get; set; }
        public Service Service { get; set; } = null!;

        public decimal Score { get; set; }
        public string Explanation { get; set; } = string.Empty;

        public bool? WasAccepted { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public ICollection<RecommendationFeedback> Feedbacks { get; set; } = new List<RecommendationFeedback>();
    }
}
