using BarberMe.Model.Requests.RecommendationFeedbacl;
using BarberMe.Model.Responses.Recommendation;

namespace BarberMe.Services.Interfaces
{
    public interface IRecommendationService
    {
        Task<List<RecommendationResponse>> GetRecommendations(int userId);

        Task AddFeedback(
            int recommendationId,
            RecommendationFeedbackInsertRequest request);
    }
}
