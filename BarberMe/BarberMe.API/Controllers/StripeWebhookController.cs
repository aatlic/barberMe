using BarberMe.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BarberMe.API.Controllers
{
    [ApiController]
    [Route("api/stripe/webhook")]
    [AllowAnonymous]
    public class StripeWebhookController : ControllerBase
    {
        private readonly IPaymentService _paymentService;
        private readonly ILogger<StripeWebhookController> _logger;

        public StripeWebhookController(
            IPaymentService paymentService,
            ILogger<StripeWebhookController> logger)
        {
            _paymentService = paymentService;
            _logger = logger;
        }

        [HttpPost]
        public async Task<IActionResult> Handle()
        {
            string json;

            using (var reader = new StreamReader(Request.Body))
            {
                json = await reader.ReadToEndAsync();
            }

            var stripeSignature =
                Request.Headers["Stripe-Signature"].ToString();

            if (string.IsNullOrWhiteSpace(stripeSignature))
            {
                return BadRequest(new
                {
                    Message = "Stripe-Signature header is missing."
                });
            }

            try
            {
                await _paymentService.HandleWebhookAsync(
                    json,
                    stripeSignature);

                return Ok();
            }
            catch (Exception ex)
            {
                _logger.LogError(
                    ex,
                    "Stripe webhook processing failed.");

                return BadRequest(new
                {
                    Message = "Stripe webhook could not be processed."
                });
            }
        }
    }
}