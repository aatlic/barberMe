using BarberMe.Model.Constants;
using BarberMe.Model.Requests.Service;
using BarberMe.Model.Responses;
using BarberMe.Model.Responses.Service;
using BarberMe.Model.SearchObjects;
using BarberMe.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BarberMe.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = Roles.Admin)]
    public class ServicesController : ControllerBase
    {
        private readonly IServiceService _service;

        public ServicesController(IServiceService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<PagedResponse<ServiceResponse>> Get([FromQuery] ServiceSearchObject search)
        {
            return await _service.GetAsync(search);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<ServiceResponse>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);

            return Ok(result);
        }

        [HttpPost]
        public async Task<ActionResult<ServiceResponse>> Insert([FromForm] ServiceInsertRequest request)
        {
            var result = await _service.InsertAsync(request);
            return Ok(result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<ServiceResponse>> Update(int id, [FromForm] ServiceUpdateRequest request)
        {
            var result = await _service.UpdateAsync(id, request);

            return Ok(result);
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<bool>> Delete(int id)
        {
            var result = await _service.DeleteAsync(id);

            return Ok(true);
        }
    }
}