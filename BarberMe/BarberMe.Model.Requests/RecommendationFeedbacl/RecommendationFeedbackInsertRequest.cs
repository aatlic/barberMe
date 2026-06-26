namespace BarberMe.Model.Requests.RecommendationFeedbacl
{
    public class RecommendationFeedbackInsertRequest
    {
        public int Rating { get; set; }

        public string? Comment { get; set; }
    }
}
