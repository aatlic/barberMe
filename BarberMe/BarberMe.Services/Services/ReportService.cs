using BarberMe.Database;
using BarberMe.Database.Context;
using BarberMe.Model.Exceptions;
using BarberMe.Model.Responses.Report;
using BarberMe.Model.SearchObjects;
using BarberMe.Services.Documents;
using BarberMe.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using QuestPDF.Fluent;

namespace BarberMe.Services
{
    public class ReportService : IReportService
    {
        private readonly BarberMeDbContext _context;

        public ReportService(BarberMeDbContext context)
        {
            _context = context;
        }

        public async Task<ReportResponse> GetReportAsync(ReportSearchObject search)
        {
            ValidateSearch(search);

            var dateFrom = search.DateFrom!.Value.Date;
            var dateToExclusive = search.DateTo!.Value.Date.AddDays(1);

            string barberName = "All barbers";

            if (search.BarberId.HasValue)
            {
                var barber = await _context.Users
                    .AsNoTracking()
                    .FirstOrDefaultAsync(
                        x => x.UserId == search.BarberId.Value &&
                             x.IsActive);

                if (barber == null)
                {
                    throw new NotFoundException(
                        "Barber was not found.");
                }

                barberName = $"{barber.FirstName} {barber.LastName}";
            }

            var query = _context.Appointments
                .AsNoTracking()
                .Include(x => x.Client)
                .Include(x => x.Barber)
                .Include(x => x.BarberService)
                    .ThenInclude(x => x.Service)
                .Include(x => x.AppointmentStatus)
                .Where(x =>
                    x.StartDateTime >= dateFrom &&
                    x.StartDateTime < dateToExclusive);

            if (search.BarberId.HasValue)
            {
                query = query.Where(
                    x => x.BarberId == search.BarberId.Value);
            }

            var appointments = await query
                .OrderBy(x => x.StartDateTime)
                .ToListAsync();

            var completedAppointments = appointments
                .Where(x => string.Equals(
                    x.AppointmentStatus.Name,
                    "Completed",
                    StringComparison.OrdinalIgnoreCase))
                .ToList();

            var reportableAppointments = appointments
                .Where(x => !string.Equals(
                    x.AppointmentStatus.Name,
                    "Cancelled",
                    StringComparison.OrdinalIgnoreCase))
                .ToList();

            var appointmentIds = appointments
                .Select(x => x.AppointmentId)
                .ToList();

            var completedPayments = await _context.Payments
                .AsNoTracking()
                .Include(x => x.PaymentStatus)
                .Where(x =>
                    appointmentIds.Contains(x.AppointmentId) &&
                    x.PaymentStatus.Name == "Completed")
                .ToListAsync();

            var paymentAmountByAppointment = completedPayments
                .GroupBy(x => x.AppointmentId)
                .ToDictionary(
                    group => group.Key,
                    group => group.Sum(x => x.Amount));

            var appointmentItems = appointments
                .Select(appointment =>
                    new ReportAppointmentItemResponse
                    {
                        AppointmentId = appointment.AppointmentId,

                        ClientName =
                            $"{appointment.Client.FirstName} " +
                            $"{appointment.Client.LastName}",

                        BarberName =
                            $"{appointment.Barber.FirstName} " +
                            $"{appointment.Barber.LastName}",

                        ServiceName =
                            appointment.BarberService.Service.Name,

                        StartDateTime =
                            appointment.StartDateTime,

                        Status =
                            appointment.AppointmentStatus.Name,

                        Price =
                            appointment.BarberService.Price,

                        IsPaid =
                            appointment.IsPaid
                    })
                .ToList();

            var serviceItems = reportableAppointments
                .GroupBy(appointment => new
                {
                    appointment.BarberService.ServiceId,
                    appointment.BarberService.Service.Name,
                    appointment.BarberService.Price
                })
                .Select(group => new ReportServiceItemResponse
                {
                    ServiceId = group.Key.ServiceId,

                    ServiceName = group.Key.Name,

                    AppointmentCount = group.Count(),

                    UnitPrice = group.Key.Price,

                    TotalRevenue = group.Sum(appointment =>
                        paymentAmountByAppointment.TryGetValue(
                            appointment.AppointmentId,
                            out var paidAmount)
                                ? paidAmount
                                : 0)
                })
                .OrderByDescending(x => x.AppointmentCount)
                .ThenBy(x => x.ServiceName)
                .ToList();

            return new ReportResponse
            {
                DateFrom = dateFrom,
                DateTo = search.DateTo.Value.Date,

                BarberId = search.BarberId,
                BarberName = barberName,

                TotalAppointments = appointments.Count,

                CompletedAppointments = completedAppointments.Count,

                CancelledAppointments = appointments.Count(
                    x => string.Equals(
                        x.AppointmentStatus.Name,
                        "Cancelled",
                        StringComparison.OrdinalIgnoreCase)),

                UniqueClients = reportableAppointments
                    .Select(x => x.ClientId)
                    .Distinct()
                    .Count(),

                TotalRevenue = completedPayments.Sum(x => x.Amount),

                Services = serviceItems,
                Appointments = appointmentItems,

                GeneratedAt = DateTime.UtcNow
            };
        }

        public async Task<byte[]> GeneratePdfAsync(
            ReportSearchObject search)
        {
            var report = await GetReportAsync(search);

            var document = new BarberReportDocument(report);

            return document.GeneratePdf();
        }

        private static void ValidateSearch(
            ReportSearchObject search)
        {
            if (!search.DateFrom.HasValue)
            {
                throw new BusinessException("DateFrom is required.");
            }

            if (!search.DateTo.HasValue)
            {
                throw new BusinessException("DateTo is required.");
            }

            if (search.DateFrom.Value.Date >
                search.DateTo.Value.Date)
            {
                throw new BusinessException("DateFrom cannot be after DateTo.");
            }

            if (search.DateTo.Value.Date >
                DateTime.UtcNow.Date.AddYears(1))
            {
                throw new BusinessException("The selected period is not valid.");
            }

            var periodLength =
                search.DateTo.Value.Date -
                search.DateFrom.Value.Date;

            if (periodLength.TotalDays > 366)
            {
                throw new BusinessException("The reporting period cannot exceed one year.");
            }

            if (search.BarberId.HasValue &&
                search.BarberId.Value <= 0)
            {
                throw new BusinessException("BarberId must be greater than zero.");
            }
        }

        public async Task<BarberPerformanceReportResponse> GetBarberPerformanceReportAsync(
            ReportSearchObject search)
        {
            ValidateSearch(search);

            var dateFrom = search.DateFrom!.Value.Date;
            var dateToExclusive = search.DateTo!.Value.Date.AddDays(1);

            var appointmentsQuery = _context.Appointments
                .AsNoTracking()
                .Include(x => x.Barber)
                .Include(x => x.BarberService)
                    .ThenInclude(x => x.Service)
                .Include(x => x.AppointmentStatus)
                .Where(x =>
                    x.StartDateTime >= dateFrom &&
                    x.StartDateTime < dateToExclusive &&
                    x.AppointmentStatus.Name == "Completed");

            if (search.BarberId.HasValue)
            {
                var barberExists = await _context.Users
                    .AsNoTracking()
                    .AnyAsync(x =>
                        x.UserId == search.BarberId.Value &&
                        x.IsActive);

                if (!barberExists)
                {
                    throw new NotFoundException("Barber was not found.");
                }

                appointmentsQuery = appointmentsQuery.Where(x => x.BarberId == search.BarberId.Value);
            }

            var completedAppointments = await appointmentsQuery.ToListAsync();

            var appointmentIds = completedAppointments
                .Select(x => x.AppointmentId)
                .ToList();

            var completedPayments = await _context.Payments
                .AsNoTracking()
                .Include(x => x.PaymentStatus)
                .Where(x =>
                    appointmentIds.Contains(x.AppointmentId) &&
                    x.PaymentStatus.Name == "Completed")
                .ToListAsync();

            var reviews = await _context.Reviews
                .AsNoTracking()
                .Where(x => appointmentIds.Contains(x.AppointmentId))
                .ToListAsync();

            var paymentAmountByAppointment = completedPayments
                .GroupBy(x => x.AppointmentId)
                .ToDictionary(
                    group => group.Key,
                    group => group.Sum(x => x.Amount));

            var barbers = completedAppointments
                .GroupBy(x => new
                {
                    x.BarberId,
                    x.Barber.FirstName,
                    x.Barber.LastName
                })
                .Select(group =>
                {
                    var barberAppointmentIds = group
                        .Select(x => x.AppointmentId)
                        .ToHashSet();

                    var barberReviews = reviews
                        .Where(x =>
                            barberAppointmentIds.Contains(x.AppointmentId))
                        .ToList();

                    var mostPopularService = group
                        .GroupBy(x => x.BarberService.Service.Name)
                        .OrderByDescending(x => x.Count())
                        .ThenBy(x => x.Key)
                        .Select(x => x.Key)
                        .FirstOrDefault();

                    return new BarberPerformanceItemResponse
                    {
                        BarberId = group.Key.BarberId,
                        BarberName =$"{group.Key.FirstName} {group.Key.LastName}",

                        CompletedAppointments = group.Count(),

                        UniqueClients = group
                            .Select(x => x.ClientId)
                            .Distinct()
                            .Count(),

                        TotalRevenue = group.Sum(appointment =>
                            paymentAmountByAppointment.TryGetValue(
                                appointment.AppointmentId,
                                out var paidAmount)
                                    ? paidAmount
                                    : 0),

                        AverageRating = barberReviews.Count > 0
                            ? Math.Round(
                                barberReviews.Average(x => x.Rating),
                                2)
                            : 0,

                        MostPopularService =
                            mostPopularService ?? "No data"
                    };
                })
                .OrderByDescending(x => x.TotalRevenue)
                .ThenByDescending(x => x.CompletedAppointments)
                .ThenBy(x => x.BarberName)
                .ToList();

            return new BarberPerformanceReportResponse
            {
                DateFrom = dateFrom,
                DateTo = search.DateTo.Value.Date,

                TotalCompletedAppointments = completedAppointments.Count,

                TotalUniqueClients = completedAppointments
                    .Select(x => x.ClientId)
                    .Distinct()
                    .Count(),

                TotalRevenue = completedPayments.Sum(x => x.Amount),

                Barbers = barbers,

                GeneratedAt = DateTime.UtcNow
            };
        }

        public async Task<byte[]> GenerateBarberPerformancePdfAsync(ReportSearchObject search)
        {
            var report = await GetBarberPerformanceReportAsync(search);

            var document = new BarberPerformanceReportDocument(report);

            return document.GeneratePdf();
        }
    }
}