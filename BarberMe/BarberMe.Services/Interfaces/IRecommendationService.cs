using BarberMe.Model.Requests.RecommendationFeedback;
using BarberMe.Model.Responses.Recommendation;

namespace BarberMe.Services.Interfaces
{
    public interface IRecommendationService
    {
        Task<List<RecommendationResponse>> GetRecommendationsAsync();

        Task<RecommendationFeedbackResponse> AddFeedbackAsync(
            int recommendationId,
            RecommendationFeedbackInsertRequest request);
    }
}