using AutoMapper;
using BarberMe.Database.Context;
using BarberMe.Database.Models;
using BarberMe.Model.Exceptions;
using BarberMe.Model.Requests.Appointment;
using BarberMe.Model.Responses;
using BarberMe.Model.Responses.Appointment;
using BarberMe.Model.SearchObjects;
using BarberMe.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace BarberMe.Services.Services
{
    public class AppointmentService: IAppointmentService
    {
        private readonly BarberMeDbContext _context;
        private readonly IMapper _mapper;

        public AppointmentService(BarberMeDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<PagedResponse<AppointmentResponse>> GetAsync(AppointmentSearchObject search)
        {
            var query = _context.Appointments
                .Include(x => x.Client)
                .Include(x => x.Barber)
                .Include(x => x.BarberService)
                    .ThenInclude(x => x.Service)
                .Include(x => x.AppointmentStatus)
                .AsQueryable();

            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                query = query.Where(x =>
                    x.Client.FirstName.Contains(search.FTS) ||
                    x.Client.LastName.Contains(search.FTS) ||
                    x.Barber.FirstName.Contains(search.FTS) ||
                    x.Barber.LastName.Contains(search.FTS));
            }

            if (search.ClientId.HasValue)
                query = query.Where(x => x.ClientId == search.ClientId.Value);

            if (search.BarberId.HasValue)
                query = query.Where(x => x.BarberId == search.BarberId.Value);

            if (search.AppointmentStatusId.HasValue)
                query = query.Where(x => x.AppointmentStatusId == search.AppointmentStatusId.Value);

            if (search.DateFrom.HasValue)
                query = query.Where(x => x.StartDateTime >= search.DateFrom.Value);

            if (search.DateTo.HasValue)
                query = query.Where(x => x.StartDateTime <= search.DateTo.Value);

            var totalCount = await query.CountAsync();

            var page = search.Page ?? 1;
            var pageSize = search.PageSize ?? 10;

            if (page < 1)
                page = 1;

            if (pageSize < 1)
                pageSize = 10;

            if (pageSize > 100)
                pageSize = 100;

            var list = await query
                .OrderByDescending(x => x.StartDateTime)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return new PagedResponse<AppointmentResponse>
            {
                Items = _mapper.Map<List<AppointmentResponse>>(list),
                TotalCount = totalCount,
                Page = page,
                PageSize = pageSize
            };
        }

        public async Task<AppointmentResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Appointments
                .Include(x => x.Client)
                .Include(x => x.Barber)
                .Include(x => x.BarberService)
                    .ThenInclude(x => x.Service)
                .Include(x => x.AppointmentStatus)
                .FirstOrDefaultAsync(x => x.AppointmentId == id);

            return entity == null ? null : _mapper.Map<AppointmentResponse>(entity);
        }

        public async Task<AppointmentResponse> InsertAsync(AppointmentInsertRequest request)
        {
            if (request.ClientId <= 0)
                throw new BusinessException("Client is required.");

            if (request.BarberServiceId <= 0)
                throw new BusinessException("Barber service is required.");

            if (request.StartDateTime <= DateTime.UtcNow)
                throw new BusinessException("Appointment date must be in the future.");

            var barberService = await _context.BarberServices
                .FirstOrDefaultAsync(x => x.BarberServiceId == request.BarberServiceId);

            if (barberService == null)
                throw new NotFoundException("Barber service does not exist.");

            var clientExists = await _context.Users
                .AnyAsync(x => x.UserId == request.ClientId && x.IsActive);

            if (!clientExists)
                throw new NotFoundException("Client does not exist.");

            var entity = _mapper.Map<Appointment>(request);

            entity.BarberId = barberService.BarberId;
            entity.EndDateTime = request.StartDateTime.AddMinutes(barberService.DurationMinutes);
            entity.AppointmentStatusId = (int)Model.Enum.AppointmentStatusType.Pending;
            entity.IsPaid = false;

            var isTaken = await _context.Appointments.AnyAsync(x =>
                x.BarberId == entity.BarberId &&
                x.CancelledAt == null &&
                request.StartDateTime < x.EndDateTime &&
                entity.EndDateTime > x.StartDateTime);

            if (isTaken)
                throw new BusinessException("Selected appointment time is already taken.");

            _context.Appointments.Add(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<AppointmentResponse>(entity);
        }

        public async Task<AppointmentResponse?> UpdateAsync(int id)
        {
            var entity = await _context.Appointments
                .FirstOrDefaultAsync(x => x.AppointmentId == id);

            if (entity == null)
                throw new NotFoundException("Appointment does not exist.");

            await _context.SaveChangesAsync();

            return _mapper.Map<AppointmentResponse>(entity);
        }

        public async Task<List<AvailableSlotResponse>> GetAvailableSlots(int barberId, int serviceId, DateOnly date)
        {
            var barberService = await _context.BarberServices
                .FirstOrDefaultAsync(x =>
                    x.BarberId == barberId &&
                    x.ServiceId == serviceId);

            if (barberService == null)
                return new List<AvailableSlotResponse>();

            var dayOfWeek = (int)date.DayOfWeek;

            var workingHours = await _context.WorkingHours
                .FirstOrDefaultAsync(x =>
                    x.BarberId == barberId &&
                    x.DayOfWeek == dayOfWeek &&
                    x.IsWorking);

            if (workingHours == null)
                return new List<AvailableSlotResponse>();

            var startDateTime = date.ToDateTime(
                TimeOnly.FromTimeSpan(workingHours.StartTime));

            var endDateTime = date.ToDateTime(
                TimeOnly.FromTimeSpan(workingHours.EndTime));

            var existingAppointments = await _context.Appointments
                .Where(x =>
                    x.BarberId == barberId &&
                    x.StartDateTime.Date == startDateTime.Date &&
                    x.CancelledAt == null)
                .ToListAsync();

            var slots = new List<AvailableSlotResponse>();

            var current = startDateTime;

            while (current.AddMinutes(barberService.DurationMinutes) <= endDateTime)
            {
                var slotEnd = current.AddMinutes(barberService.DurationMinutes);

                var isTaken = existingAppointments.Any(x =>
                    current < x.EndDateTime &&
                    slotEnd > x.StartDateTime);

                if (!isTaken)
                {
                    slots.Add(new AvailableSlotResponse
                    {
                        StartDateTime = current,
                        EndDateTime = slotEnd
                    });
                }

                current = current.AddMinutes(barberService.DurationMinutes);
            }

            return slots;
        }

        public async Task CancelAppointment(int id, AppointmentUpdateRequest request)
        {
            var entity = await _context.Appointments
                .FirstOrDefaultAsync(x => x.AppointmentId == id);

            if (entity == null)
                throw new NotFoundException("Appointment does not exist.");

            if (entity.CancelledAt != null)
                throw new BusinessException("Appointment is already cancelled.");

            if (entity.CompletedAt != null)
                throw new BusinessException("Completed appointment cannot be cancelled.");

            entity.CancelledAt = DateTime.UtcNow;
            _mapper.Map(request, entity);

            await _context.SaveChangesAsync();
        }

        public async Task ConfirmAppointment(int id)
        {
            var entity = await _context.Appointments
                .FirstOrDefaultAsync(x => x.AppointmentId == id);

            if (entity == null)
                throw new NotFoundException("Appointment does not exist.");

            if (entity.CancelledAt != null)
                throw new BusinessException("Cancelled appointment cannot be confirmed.");

            if (entity.ConfirmedAt != null)
                throw new BusinessException("Appointment is already confirmed.");

            entity.ConfirmedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
        }
    }
}
