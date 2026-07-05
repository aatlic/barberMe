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
    [Authorize]
    public class NewsController : ControllerBase
    {
        private readonly INewsService _service;

        public NewsController(INewsService service)
        {
            _service = service;
        }

        [HttpGet]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Barber},{Roles.Client}")]
        public async Task<PagedResponse<NewsResponse>> Get([FromQuery] NewsSearchObject search)
        {
            return await _service.GetAsync(search);
        }

        [HttpGet("{id}")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Barber},{Roles.Client}")]
        public async Task<ActionResult<NewsResponse>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);

            return Ok(result);
        }

        [HttpPost]
        [Authorize(Roles = Roles.Admin)]
        public async Task<ActionResult<NewsResponse>> Insert(NewsInsertRequest request)
        {
            var result = await _service.InsertAsync(request);
            return Ok(result);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = Roles.Admin)]
        public async Task<ActionResult<NewsResponse>> Update(int id, NewsUpdateRequest request)
        {
            var result = await _service.UpdateAsync(id, request);

            return Ok(result);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = Roles.Admin)]
        public async Task<ActionResult<bool>> Delete(int id)
        {
            var result = await _service.DeleteAsync(id);

            return Ok(true);
        }
    }
}