namespace BarberMe.Model.Responses.Recommendation
{
    public class RecommendationFeedbackResponse : BaseResponse
    {
        public int RecommendationId { get; set; }

        public int Rating { get; set; }

        public string? Comment { get; set; }

        public DateTime CreatedAt { get; set; }
    }
}
