using BarberMe.Model.Requests.Notification;
using BarberMe.Model.Responses;
using BarberMe.Model.Responses.Notification;
using BarberMe.Model.SearchObjects;
using BarberMe.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace BarberMe.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class NewsController : ControllerBase
    {
        private readonly INewsService _service;

        public NewsController(INewsService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<PagedResponse<NewsResponse>> Get([FromQuery] NewsSearchObject search)
        {
            return await _service.GetAsync(search);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<NewsResponse>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);

            if (result == null)
                return NotFound();

            return Ok(result);
        }

        [HttpPost]
        public async Task<ActionResult<NewsResponse>> Insert(NewsInsertRequest request)
        {
            var result = await _service.InsertAsync(request);
            return Ok(result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<NewsResponse>> Update(int id, NewsUpdateRequest request)
        {
            var result = await _service.UpdateAsync(id, request);

            if (result == null)
                return NotFound();

            return Ok(result);
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<bool>> Delete(int id)
        {
            var result = await _service.DeleteAsync(id);

            if (!result)
                return NotFound(false);

            return Ok(true);
        }
    }
}