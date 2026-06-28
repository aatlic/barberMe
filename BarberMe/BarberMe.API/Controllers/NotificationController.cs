using BarberMe.Model.Constants;
using BarberMe.Model.Requests.Notification;
using BarberMe.Model.Responses;
using BarberMe.Model.Responses.Notification;
using BarberMe.Model.SearchObjects;
using BarberMe.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BarberMe.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = $"{Roles.Admin},{Roles.Barber},{Roles.Client}")]
    public class NotificationsController : ControllerBase
    {
        private readonly INotificationService _service;

        public NotificationsController(INotificationService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<PagedResponse<NotificationResponse>> Get(
            [FromQuery] NotificationSearchObject search)
        {
            return await _service.GetAsync(search);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<NotificationResponse>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);

            return Ok(result);
        }

        [HttpPost]
        [Authorize(Roles = Roles.Admin)]
        public async Task<ActionResult<NotificationResponse>> Insert(
            NotificationInsertRequest request)
        {
            var result = await _service.InsertAsync(request);
            return Ok(result);
        }

        [HttpPut("{id}/read")]
        public async Task<IActionResult> MarkAsRead(int id)
        {
            await _service.MarkAsRead(id);
            return Ok();
        }

        [HttpGet("unread-count/{userId}")]
        public async Task<ActionResult<int>> GetUnreadCount(int userId)
        {
            var result = await _service.GetUnreadCount(userId);
            return Ok(result);
        }
    }
}