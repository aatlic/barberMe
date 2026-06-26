using BarberMe.Model.Requests.BarberService;
using BarberMe.Model.Responses;
using BarberMe.Model.Responses.Service;
using BarberMe.Model.SearchObjects;
using BarberMe.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace BarberMe.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class BarberServicesController : ControllerBase
    {
        private readonly IBarberService _service;

        public BarberServicesController(IBarberService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<PagedResponse<BarberServiceResponse>> Get(
            [FromQuery] BarberServiceSearchObject search)
        {
            return await _service.GetAsync(search);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<BarberServiceResponse>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);

            if (result == null)
                return NotFound();

            return Ok(result);
        }

        [HttpPost]
        public async Task<ActionResult<BarberServiceResponse>> Insert(
            BarberServiceInsertRequest request)
        {
            var result = await _service.InsertAsync(request);
            return Ok(result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<BarberServiceResponse>> Update(
            int id,
            BarberServiceUpdateRequest request)
        {
            var result = await _service.UpdateAsync(id, request);

            if (result == null)
                return NotFound();

            return Ok(result);
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<bool>> Delete(int id)
        {
            var result = await _service.DeleteAsync(id);

            if (!result)
                return NotFound(false);

            return Ok(true);
        }
    }
}