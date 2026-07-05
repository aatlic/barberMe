using BarberMe.Model.Constants;
using BarberMe.Model.Requests.WorkingHours;
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
    public class WorkingHoursController : ControllerBase
    {
        private readonly IWorkingHoursService _service;

        public WorkingHoursController(IWorkingHoursService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<PagedResponse<WorkingHoursResponse>> Get(
            [FromQuery] WorkingHoursSearchObject search)
        {
            return await _service.GetAsync(search);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<WorkingHoursResponse>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);

            return Ok(result);
        }

        [HttpGet("barber/{barberId}")]
        public async Task<ActionResult<List<WorkingHoursResponse>>> GetByBarber(int barberId)
        {
            var result = await _service.GetByBarberAsync(barberId);
            return Ok(result);
        }

        [HttpPost]
        public async Task<ActionResult<WorkingHoursResponse>> Insert(
            WorkingHoursInsertRequest request)
        {
            var result = await _service.InsertAsync(request);
            return Ok(result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<WorkingHoursResponse>> Update(
            int id,
            WorkingHoursUpdateRequest request)
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