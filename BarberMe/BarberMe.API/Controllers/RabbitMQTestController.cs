using BarberMe.API.Messaging;
using BarberMe.Model.Enum;
using BarberMe.Model.Messaging;
using Microsoft.AspNetCore.Mvc;

namespace BarberMe.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class RabbitMQTestController : ControllerBase
    {
        private readonly IRabbitMQPublisher _publisher;

        public RabbitMQTestController(IRabbitMQPublisher publisher)
        {
            _publisher = publisher;
        }

        [HttpPost("send")]
        public async Task<IActionResult> Send(
            CancellationToken cancellationToken)
        {
            var message = new NotificationMessage
            {
                UserId = 1,
                NotificationTypeId = NotificationTypeEnum.Reservation,
                Title = "Test notifikacija",
                Text = "Ovo je testna tipizirana RabbitMQ poruka.",
                EventType = "TestNotification",
                CreatedAt = DateTime.UtcNow
            };

            await _publisher.PublishAsync(message, cancellationToken);

            return Ok(new
            {
                message = "Notification message sent to RabbitMQ."
            });
        }
    }
}