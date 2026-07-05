using BarberMe.Model.Requests.RecommendationFeedback;
using BarberMe.Model.Responses.Recommendation;

namespace BarberMe.Services.Interfaces
{
    public interface IRecommendationService
    {
        Task<List<RecommendationResponse>> GetRecommendations();

        Task AddFeedback(int recommendationId, RecommendationFeedbackInsertRequest request);
    }
}
