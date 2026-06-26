using BarberMe.Model.Requests.Review;
using BarberMe.Model.Responses;
using BarberMe.Model.Responses.Appointment;
using BarberMe.Model.SearchObjects;
using BarberMe.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace BarberMe.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ReviewsController : ControllerBase
    {
        private readonly IReviewService _service;

        public ReviewsController(IReviewService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<PagedResponse<ReviewResponse>> Get([FromQuery] ReviewSearchObject search)
        {
            return await _service.GetAsync(search);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<ReviewResponse>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);

            if (result == null)
                return NotFound();

            return Ok(result);
        }

        [HttpPost]
        public async Task<ActionResult<ReviewResponse>> Insert(ReviewInsertRequest request)
        {
            var result = await _service.InsertAsync(request);
            return Ok(result);
        }
    }
}