using BarberMe.Model.Responses;
using BarberMe.Model.Responses.User;
using BarberMe.Model.SearchObjects;
using BarberMe.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace BarberMe.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class RolesController : ControllerBase
    {
        private readonly IRoleService _service;

        public RolesController(IRoleService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<PagedResponse<RoleResponse>> Get(
            [FromQuery] BaseSearchObject search)
        {
            return await _service.GetAsync(search);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<RoleResponse>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);

            if (result == null)
                return NotFound();

            return Ok(result);
        }
    }
}