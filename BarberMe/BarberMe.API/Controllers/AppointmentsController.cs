using BarberMe.Model.Constants;
using BarberMe.Model.Requests.Appointment;
using BarberMe.Model.Responses;
using BarberMe.Model.Responses.Appointment;
using BarberMe.Model.SearchObjects;
using BarberMe.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BarberMe.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = $"{Roles.Admin},{Roles.Barber},{Roles.Client}")]
    public class AppointmentsController : ControllerBase
    {
        private readonly IAppointmentService _service;

        public AppointmentsController(IAppointmentService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<PagedResponse<AppointmentResponse>> Get([FromQuery] AppointmentSearchObject search)
        {
            return await _service.GetAsync(search);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<AppointmentResponse>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);

            if (result == null)
                return NotFound();

            return Ok(result);
        }

        [HttpPost]
        public async Task<ActionResult<AppointmentResponse>> Insert(AppointmentInsertRequest request)
        {
            var result = await _service.InsertAsync(request);
            return Ok(result);
        }

        [HttpGet("available-slots")]
        public async Task<ActionResult<List<AvailableSlotResponse>>> GetAvailableSlots(
            [FromQuery] int barberId,
            [FromQuery] int serviceId,
            [FromQuery] DateOnly date)
        {
            var result = await _service.GetAvailableSlots(barberId, serviceId, date);
            return Ok(result);
        }

        [HttpPut("{id}/cancel")]
        public async Task<IActionResult> Cancel(int id, CancelAppointmentRequest request)
        {
            await _service.CancelAppointment(id, request);
            return Ok();
        }

        [HttpPut("{id}/confirm")]
        [Authorize(Roles = $"{Roles.Barber},{Roles.Admin}")]
        public async Task<IActionResult> Confirm(int id)
        {
            await _service.ConfirmAppointment(id);
            return Ok();
        }

        [HttpPut("{id}/complete")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Barber}")]
        public async Task<IActionResult> CompleteAppointment(int id)
        {
            await _service.CompleteAppointment(id);
            return Ok();
        }

        [HttpPut("{id}/reschedule")]
        [Authorize(Roles = $"{Roles.Client},{Roles.Barber},{Roles.Admin}")]
        public async Task<bool> Reschedule(int id, AppointmentRescheduleRequest request)
        {
            return await _service.RescheduleAsync(id, request);
        }

        [HttpPost("{id}/no-show")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Barber}")]
        public async Task<IActionResult> MarkAsNoShow(int id)
        {
            await _service.MarkAsNoShowAsync(id);

            return NoContent();
        }

        [HttpPut("{id}/reminder")]
        public async Task<IActionResult> UpdateReminder(
            int id,
            AppointmentReminderRequest request)
        {
            await _service.UpdateReminderAsync(id, request);

            return NoContent();
        }

        [HttpGet("availability-calendar")]
        public async Task<ActionResult<List<CalendarAvailabilityResponse>>> GetCalendarAvailability(
            [FromQuery] int barberId,
            [FromQuery] int serviceId,
            [FromQuery] int year,
            [FromQuery] int month)
        {
            var result =
                await _service.GetCalendarAvailabilityAsync(
                    barberId,
                    serviceId,
                    year,
                    month);

            return Ok(result);
        }
    }
}