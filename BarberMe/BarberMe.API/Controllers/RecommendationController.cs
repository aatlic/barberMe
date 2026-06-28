using BarberMe.Model.Constants;
using BarberMe.Model.Requests.RecommendationFeedbacl;
using BarberMe.Model.Responses.Recommendation;
using BarberMe.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BarberMe.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = $"{Roles.Client},{Roles.Admin}")]
    public class RecommendationController : ControllerBase
    {
        private readonly IRecommendationService _service;

        public RecommendationController(IRecommendationService service)
        {
            _service = service;
        }

        [HttpGet("{userId}")]
        public async Task<ActionResult<List<RecommendationResponse>>> GetRecommendations(int userId)
        {
            var result = await _service.GetRecommendations(userId);
            return Ok(result);
        }

        [HttpPost("{recommendationId}/feedback")]
        public async Task<IActionResult> AddFeedback(
            int recommendationId,
            RecommendationFeedbackInsertRequest request)
        {
            await _service.AddFeedback(
                recommendationId,
                request);

            return Ok();
        }
    }
}