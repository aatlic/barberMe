using BarberMe.Model.Constants;
using BarberMe.Model.Requests.BarberLevel;
using BarberMe.Model.Responses;
using BarberMe.Model.Responses.User;
using BarberMe.Model.SearchObjects;
using BarberMe.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BarberMe.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = Roles.Admin)]
    public class BarberLevelsController : ControllerBase
    {
        private readonly IBarberLevelService _service;

        public BarberLevelsController(IBarberLevelService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<PagedResponse<BarberLevelResponse>> Get(
            [FromQuery] BarberLevelSearchObject search)
        {
            return await _service.GetAsync(search);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<BarberLevelResponse>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);

            return Ok(result);
        }

        [HttpPost]
        public async Task<ActionResult<BarberLevelResponse>> Insert(
            BarberLevelInsertRequest request)
        {
            var result = await _service.InsertAsync(request);
            return Ok(result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<BarberLevelResponse>> Update(
            int id,
            BarberLevelUpdateRequest request)
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