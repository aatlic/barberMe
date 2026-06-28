using BarberMe.Model.Constants;
using BarberMe.Model.Requests.Refund;
using BarberMe.Model.Responses.Payment;
using BarberMe.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BarberMe.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = $"{Roles.Client},{Roles.Admin}")]
    public class RefundsController : ControllerBase
    {
        private readonly IRefundService _service;

        public RefundsController(IRefundService service)
        {
            _service = service;
        }

        [HttpPost]
        public async Task<ActionResult<RefundResponse>> Insert(
            RefundInsertRequest request)
        {
            var result = await _service.InsertAsync(request);

            return Ok(result);
        }
    }
}