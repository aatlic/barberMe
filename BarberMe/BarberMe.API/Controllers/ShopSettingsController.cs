using BarberMe.Model.Requests.ShopSettings;
using BarberMe.Model.Responses;
using BarberMe.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BarberMe.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ShopSettingsController : ControllerBase
    {
        private readonly IShopSettingsService _service;

        public ShopSettingsController(IShopSettingsService service)
        {
            _service = service;
        }

        [HttpGet]
        [AllowAnonymous]
        public async Task<ActionResult<ShopSettingsResponse>> Get()
        {
            var result = await _service.GetAsync();
            return Ok(result);
        }

        [HttpPut]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<ShopSettingsResponse>> Update(
            ShopSettingsUpdateRequest request)
        {
            var result = await _service.UpdateAsync(request);
            return Ok(result);
        }
    }
}