using BarberMe.Model.Requests.Support;
using BarberMe.Model.Responses;
using BarberMe.Model.Responses.Support;
using BarberMe.Model.SearchObjects;
using BarberMe.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace BarberMe.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class SupportRequestsController : ControllerBase
    {
        private readonly ISupportRequestService _service;

        public SupportRequestsController(ISupportRequestService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<PagedResponse<SupportRequestResponse>> Get(
            [FromQuery] SupportRequestSearchObject search)
        {
            return await _service.GetAsync(search);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<SupportRequestResponse>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);

            if (result == null)
                return NotFound();

            return Ok(result);
        }

        [HttpPost]
        public async Task<ActionResult<SupportRequestResponse>> Insert(
            SupportRequestInsertRequest request)
        {
            var result = await _service.InsertAsync(request);
            return Ok(result);
        }

        [HttpPut("{id}/resolve")]
        public async Task<IActionResult> Resolve(int id)
        {
            await _service.ResolveAsync(id);
            return Ok();
        }
    }
}