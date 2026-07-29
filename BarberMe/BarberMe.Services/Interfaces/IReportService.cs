using BarberMe.Model.Responses.Report;
using BarberMe.Model.SearchObjects;

namespace BarberMe.Services.Interfaces
{
    public interface IReportService
    {
        Task<ReportResponse> GetReportAsync(ReportSearchObject search);

        Task<byte[]> GeneratePdfAsync(ReportSearchObject search);
    }
}