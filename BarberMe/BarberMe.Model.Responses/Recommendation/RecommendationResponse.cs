namespace BarberMe.Model.Responses.Recommendation
{
    public class RecommendationResponse
    {
        public int RecommendationId { get; set; }

        public int BarberServiceId { get; set; }

        public int ServiceId { get; set; }

        public string ServiceName { get; set; } = string.Empty;

        public int BarberId { get; set; }

        public string BarberName { get; set; } = string.Empty;

        public decimal Price { get; set; }

        public int DurationMinutes { get; set; }

        public decimal Score { get; set; }

        public string Explanation { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; }
    }
}