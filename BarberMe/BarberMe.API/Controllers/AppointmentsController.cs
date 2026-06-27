using BarberMe.Model.Exceptions;
using BarberMe.Model.Requests.Appointment;
using BarberMe.Model.Responses;
using BarberMe.Model.Responses.Appointment;
using BarberMe.Model.SearchObjects;
using BarberMe.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace BarberMe.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
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

        [HttpPut("{id}")]
        public async Task<ActionResult<AppointmentResponse>> Update(int id)
        {
            var result = await _service.UpdateAsync(id);

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
        public async Task<IActionResult> Cancel(int id, AppointmentUpdateRequest request)
        {
            await _service.CancelAppointment(id, request);
            return Ok();
        }

        [HttpPut("{id}/confirm")]
        public async Task<IActionResult> Confirm(int id)
        {
            await _service.ConfirmAppointment(id);
            return Ok();
        }
    }
}