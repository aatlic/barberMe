using BarberMe.Model.Constants;
using BarberMe.Model.Responses.Report;
using BarberMe.Model.SearchObjects;
using BarberMe.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BarberMe.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = Roles.Admin)]
    public class ReportsController : ControllerBase
    {
        private readonly IReportService _service;

        public ReportsController(IReportService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<ActionResult<ReportResponse>> GetReport([FromQuery] ReportSearchObject search)
        {
            var result = await _service.GetReportAsync(search);

            return Ok(result);
        }

        [HttpGet("pdf")]
        public async Task<IActionResult> DownloadPdf([FromQuery] ReportSearchObject search)
        {
            var pdf = await _service.GeneratePdfAsync(search);

            var fileName =
                $"barber-report-" +
                $"{search.DateFrom:yyyyMMdd}-" +
                $"{search.DateTo:yyyyMMdd}.pdf";

            return File(
                pdf,
                "application/pdf",
                fileName);
        }

        [HttpGet("barber-performance/pdf")]
        [Authorize(Roles = Roles.Admin)]
        public async Task<IActionResult> GetBarberPerformancePdf([FromQuery] ReportSearchObject search)
        {
            var pdf = await _service.GenerateBarberPerformancePdfAsync(search);

            var barber = search.BarberId.HasValue
                ? $"-{search.BarberId.Value}"
                : "-all";

            var fileName =
                $"barber-performance-{search.DateFrom:yyyyMMdd}-{search.DateTo:yyyyMMdd}{barber}.pdf";

            return File(
                pdf,
                "application/pdf",
                fileName);
        }
    }
}