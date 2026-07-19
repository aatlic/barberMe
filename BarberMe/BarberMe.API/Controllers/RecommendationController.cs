using BarberMe.Model.Constants;
using BarberMe.Model.Requests.RecommendationFeedback;
using BarberMe.Model.Responses.Recommendation;
using BarberMe.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BarberMe.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = Roles.Client)]
    public class RecommendationController : ControllerBase
    {
        private readonly IRecommendationService _service;

        public RecommendationController(IRecommendationService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<ActionResult<List<RecommendationResponse>>>
            GetRecommendations()
        {
            var result = await _service.GetRecommendationsAsync();

            return Ok(result);
        }

        [HttpPost("{recommendationId:int}/feedback")]
        public async Task<ActionResult<RecommendationFeedbackResponse>>
            AddFeedback(
                int recommendationId,
                [FromBody] RecommendationFeedbackInsertRequest request)
        {
            var result = await _service.AddFeedbackAsync(
                recommendationId,
                request);

            return Ok(result);
        }
    }
}