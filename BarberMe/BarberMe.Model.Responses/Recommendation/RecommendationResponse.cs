using BarberMe.Model.Responses.Service;

namespace BarberMe.Model.Responses.Recommendation
{
    public class RecommendationResponse : BaseResponse
    {
        public ServiceResponse Service { get; set; } = null!;

        public decimal Score { get; set; }

        public string Explanation { get; set; } = null!;
    }
}
