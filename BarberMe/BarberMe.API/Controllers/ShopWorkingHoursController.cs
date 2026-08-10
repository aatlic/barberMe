using BarberMe.Model.Requests.ShopWorkingHours;
using BarberMe.Model.Responses;
using BarberMe.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BarberMe.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ShopWorkingHoursController : ControllerBase
    {
        private readonly IShopWorkingHoursService _service;

        public ShopWorkingHoursController(
            IShopWorkingHoursService service)
        {
            _service = service;
        }

        [HttpGet]
        [AllowAnonymous]
        public async Task<ActionResult<List<ShopWorkingHoursResponse>>> Get()
        {
            var result = await _service.GetAsync();

            return Ok(result);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<ShopWorkingHoursResponse>> Update(
            int id,
            ShopWorkingHoursUpdateRequest request)
        {
            var result = await _service.UpdateAsync(id, request);

            return Ok(result);
        }
    }
}