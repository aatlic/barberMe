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
    [Authorize]
    public class PaymentsController : ControllerBase
    {
        private readonly IPaymentService _service;

        public PaymentsController(IPaymentService service)
        {
            _service = service;
        }

        [HttpPost("appointments/{appointmentId}")]
        [Authorize(Roles = Roles.Client)]
        public async Task<ActionResult<PaymentResponse>> CreatePayment(
            int appointmentId)
        {
            var result = await _service.CreatePayment(appointmentId);

            return Ok(result);
        }

        [HttpPost("{paymentId}/confirm")]
        [Authorize(Roles = Roles.Client)]
        public async Task<ActionResult<bool>> ConfirmPayment(int paymentId)
        {
            var result = await _service.ConfirmPayment(paymentId);
            return Ok(result);
        }

        [HttpPost("{paymentId}/refund")]
        [Authorize(Roles = Roles.Admin)]
        public async Task<ActionResult<RefundResponse>> RefundPayment(
            int paymentId,
            [FromBody] RefundInsertRequest request)
        {
            var result = await _service.RefundPaymentAsync(
                paymentId,
                request);

            return Ok(result);
        }

        [HttpPost("{paymentId}/simulate-success")]
        [Authorize(Roles = Roles.Client)]
        public async Task<ActionResult<bool>> SimulateSuccessfulPayment(int paymentId)
        {
            var result = await _service.SimulateSuccessfulPayment(paymentId);
            return Ok(result);
        }
    }
}