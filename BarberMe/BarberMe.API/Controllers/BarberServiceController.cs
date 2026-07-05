using BarberMe.Model.Constants;
using BarberMe.Model.Requests.BarberService;
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
    public class BarberServicesController : ControllerBase
    {
        private readonly IBarberService _service;

        public BarberServicesController(IBarberService service)
        {
            _service = service;
        }

        [HttpGet]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Barber},{Roles.Client}")]
        public async Task<PagedResponse<BarberServiceResponse>> Get(
            [FromQuery] BarberServiceSearchObject search)
        {
            return await _service.GetAsync(search);
        }

        [HttpGet("{id}")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Barber},{Roles.Client}")]
        public async Task<ActionResult<BarberServiceResponse>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);

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