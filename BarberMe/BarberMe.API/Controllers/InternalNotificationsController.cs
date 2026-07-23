using BarberMe.API.SignalR;
using BarberMe.Model.Messaging;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BarberMe.API.Controllers
{
    [ApiController]
    [Route("api/internal/notifications")]
    [AllowAnonymous]
    [ApiExplorerSettings(IgnoreApi = true)]
    public class InternalNotificationsController : ControllerBase
    {
        private readonly INotificationHubService _notificationHubService;
        private readonly IConfiguration _configuration;

        public InternalNotificationsController(
            INotificationHubService notificationHubService,
            IConfiguration configuration)
        {
            _notificationHubService = notificationHubService;
            _configuration = configuration;
        }

        [HttpPost("send")]
        public async Task<IActionResult> Send(
            [FromBody] NotificationMessage message,
            [FromHeader(Name = "X-Internal-Api-Key")] string? apiKey)
        {
            var expectedKey = _configuration["InternalApi:Key"];

            if (string.IsNullOrWhiteSpace(expectedKey) ||
                apiKey != expectedKey)
            {
                return Unauthorized();
            }

            if (message.UserId <= 0)
            {
                return BadRequest(new
                {
                    message = "UserId is required."
                });
            }

            await _notificationHubService.SendToUserAsync(message);

            return NoContent();
        }
    }
}