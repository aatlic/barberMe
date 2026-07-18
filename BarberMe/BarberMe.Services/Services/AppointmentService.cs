using AutoMapper;
using BarberMe.Database.Context;
using BarberMe.Database.Models;
using BarberMe.Model.Constants;
using BarberMe.Model.Exceptions;
using BarberMe.Model.Requests.Appointment;
using BarberMe.Model.Responses;
using BarberMe.Model.Responses.Appointment;
using BarberMe.Model.SearchObjects;
using BarberMe.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace BarberMe.Services.Services
{
    public class AppointmentService : IAppointmentService
    {
        private readonly BarberMeDbContext _context;
        private readonly IMapper _mapper;
        private readonly ICurrentUserService _currentUserService;

        public AppointmentService(
            BarberMeDbContext context,
            IMapper mapper,
            ICurrentUserService currentUserService)
        {
            _context = context;
            _mapper = mapper;
            _currentUserService = currentUserService;
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

            if (_currentUserService.Role == Roles.Client)
            {
                query = query.Where(x => x.ClientId == _currentUserService.UserId);
            }
            else if (_currentUserService.Role == Roles.Barber)
            {
                query = query.Where(x => x.BarberId == _currentUserService.UserId);
            }
            else if (_currentUserService.Role == Roles.Admin)
            {
                if (search.ClientId.HasValue)
                    query = query.Where(x => x.ClientId == search.ClientId.Value);

                if (search.BarberId.HasValue)
                    query = query.Where(x => x.BarberId == search.BarberId.Value);
            }

            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                query = query.Where(x =>
                    x.Client.FirstName.Contains(search.FTS) ||
                    x.Client.LastName.Contains(search.FTS) ||
                    x.Barber.FirstName.Contains(search.FTS) ||
                    x.Barber.LastName.Contains(search.FTS));
            }

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

            if (entity == null)
                throw new NotFoundException("Appointment does not exist.");

            ValidateAppointmentAccess(entity);

            return _mapper.Map<AppointmentResponse>(entity);
        }

        public async Task<AppointmentResponse> InsertAsync(AppointmentInsertRequest request)
        {
            var clientId = request.ClientId;

            if (_currentUserService.Role == Roles.Client)
            {
                clientId = _currentUserService.UserId;
            }
            else if (clientId <= 0)
            {
                throw new BusinessException("Client is required.");
            }

            if (request.BarberServiceId <= 0)
            {
                throw new BusinessException("Barber service is required.");
            }

            if (request.StartDateTime <= DateTime.UtcNow)
            {
                throw new BusinessException("Appointment date must be in the future.");
            }

            var barberService = await _context.BarberServices
                .Include(x => x.Barber)
                .Include(x => x.Service)
                .FirstOrDefaultAsync(x =>
                    x.BarberServiceId == request.BarberServiceId);

            if (barberService == null)
            {
                throw new NotFoundException("Barber service does not exist.");
            }

            if (!barberService.Barber.IsActive)
            {
                throw new BusinessException("Selected barber is not active.");
            }

            if (!barberService.Service.IsActive)
            {
                throw new BusinessException("Selected service is not active.");
            }

            var clientExists = await _context.Users
                .Include(x => x.Role)
                .AnyAsync(x =>
                    x.UserId == clientId &&
                    x.IsActive &&
                    x.Role.Name == Roles.Client);

            if (!clientExists)
            {
                throw new NotFoundException("Active client does not exist.");
            }

            var entity = _mapper.Map<Appointment>(request);

            entity.ClientId = clientId;
            entity.BarberId = barberService.BarberId;
            entity.EndDateTime = request.StartDateTime
                .AddMinutes(barberService.DurationMinutes);
            entity.AppointmentStatusId =
                (int)Model.Enum.AppointmentStatusType.Pending;
            entity.IsPaid = false;

            await ValidateBarberWorkingHours(
                entity.BarberId,
                entity.StartDateTime,
                entity.EndDateTime);

            var isTaken = await _context.Appointments
                .AnyAsync(x =>
                    x.BarberId == entity.BarberId &&
                    x.AppointmentStatusId !=
                        (int)Model.Enum.AppointmentStatusType.Cancelled &&
                    entity.StartDateTime < x.EndDateTime &&
                    entity.EndDateTime > x.StartDateTime);

            if (isTaken)
            {
                throw new BusinessException("Selected appointment time is already taken.");
            }

            _context.Appointments.Add(entity);
            await _context.SaveChangesAsync();

            var createdAppointment = await _context.Appointments
                .AsNoTracking()
                .Include(x => x.Client)
                .Include(x => x.Barber)
                .Include(x => x.BarberService)
                    .ThenInclude(x => x.Service)
                .Include(x => x.AppointmentStatus)
                .FirstAsync(x =>
                    x.AppointmentId == entity.AppointmentId);

            return _mapper.Map<AppointmentResponse>(
                createdAppointment);
        }

        public async Task<List<AvailableSlotResponse>> GetAvailableSlots(
            int barberId,
            int serviceId,
            DateOnly date)
        {
            var barberService = await _context.BarberServices
                .Include(x => x.Barber)
                .Include(x => x.Service)
                .FirstOrDefaultAsync(x =>
                    x.BarberId == barberId &&
                    x.ServiceId == serviceId);

            if (barberService == null ||
                !barberService.Barber.IsActive ||
                !barberService.Service.IsActive)
            {
                return new List<AvailableSlotResponse>();
            }

            var dayOfWeek = (int)date.DayOfWeek;

            var workingHoursList = await _context.WorkingHours
                .Where(x =>
                    x.BarberId == barberId &&
                    x.DayOfWeek == dayOfWeek &&
                    x.IsWorking)
                .OrderBy(x => x.StartTime)
                .ToListAsync();

            if (!workingHoursList.Any())
                return new List<AvailableSlotResponse>();

            var dayStart = date.ToDateTime(TimeOnly.MinValue);
            var dayEnd = date.ToDateTime(TimeOnly.MaxValue);

            var existingAppointments = await _context.Appointments
                .Where(x =>
                    x.BarberId == barberId &&
                    x.StartDateTime >= dayStart &&
                    x.StartDateTime <= dayEnd &&
                    x.AppointmentStatusId != (int)Model.Enum.AppointmentStatusType.Cancelled)
                .ToListAsync();

            var slots = new List<AvailableSlotResponse>();

            foreach (var workingHours in workingHoursList)
            {
                var startDateTime = date.ToDateTime(TimeOnly.FromTimeSpan(workingHours.StartTime));
                var endDateTime = date.ToDateTime(TimeOnly.FromTimeSpan(workingHours.EndTime));

                var current = startDateTime;

                while (current.AddMinutes(barberService.DurationMinutes) <= endDateTime)
                {
                    var slotEnd = current.AddMinutes(barberService.DurationMinutes);

                    var isTaken = existingAppointments.Any(x =>
                        IsOverlapping(current, slotEnd, x.StartDateTime, x.EndDateTime));

                    if (!isTaken && current > DateTime.UtcNow)
                    {
                        slots.Add(new AvailableSlotResponse
                        {
                            StartDateTime = current,
                            EndDateTime = slotEnd
                        });
                    }

                    current = current.AddMinutes(barberService.DurationMinutes);
                }
            }

            return slots;
        }

        public async Task CancelAppointment(int id, CancelAppointmentRequest request)
        {
            var entity = await _context.Appointments
                .FirstOrDefaultAsync(x => x.AppointmentId == id);

            if (entity == null)
                throw new NotFoundException("Appointment does not exist.");

            ValidateAppointmentAccess(entity);

            if (entity.AppointmentStatusId == (int)Model.Enum.AppointmentStatusType.Cancelled)
                throw new BusinessException("Appointment is already cancelled.");

            if (entity.AppointmentStatusId == (int)Model.Enum.AppointmentStatusType.Completed)
                throw new BusinessException("Completed appointment cannot be cancelled.");

            if (entity.StartDateTime <= DateTime.UtcNow)
                throw new BusinessException("Appointment cannot be cancelled after it has started.");

            if (string.IsNullOrWhiteSpace(request.CancellationReason))
                throw new BusinessException("Cancellation reason is required.");

            if (entity.IsPaid)
            {
                throw new BusinessException("A paid appointment cannot be cancelled before its refund is processed.");
            }

            entity.AppointmentStatusId = (int)Model.Enum.AppointmentStatusType.Cancelled;
            entity.CancelledAt = DateTime.UtcNow;
            entity.CancelledById = _currentUserService.UserId;
            entity.CancellationReason = request.CancellationReason.Trim();

            await _context.SaveChangesAsync();
        }

        public async Task ConfirmAppointment(int id)
        {
            var entity = await _context.Appointments
                .FirstOrDefaultAsync(x => x.AppointmentId == id);

            if (entity == null)
                throw new NotFoundException("Appointment does not exist.");

            ValidateAppointmentManagementAccess(entity);

            if (entity.AppointmentStatusId != (int)Model.Enum.AppointmentStatusType.Pending)
                throw new BusinessException("Only pending appointments can be confirmed.");

            if (entity.StartDateTime <= DateTime.UtcNow)
                throw new BusinessException("Past appointments cannot be confirmed.");

            entity.AppointmentStatusId = (int)Model.Enum.AppointmentStatusType.Confirmed;

            entity.ConfirmedAt = DateTime.UtcNow;
            entity.ConfirmedById = _currentUserService.UserId;

            entity.CancelledAt = null;
            entity.CancelledById = null;
            entity.CancellationReason = null;

            await _context.SaveChangesAsync();
        }

        public async Task CompleteAppointment(int id)
        {
            var entity = await _context.Appointments
                .FirstOrDefaultAsync(x => x.AppointmentId == id);

            if (entity == null)
                throw new NotFoundException("Appointment does not exist.");

            ValidateAppointmentManagementAccess(entity);

            if (entity.AppointmentStatusId != (int)Model.Enum.AppointmentStatusType.Confirmed)
                throw new BusinessException("Only confirmed appointments can be completed.");

            if (entity.EndDateTime > DateTime.UtcNow)
                throw new BusinessException("Appointment cannot be completed before it ends.");

            entity.AppointmentStatusId = (int)Model.Enum.AppointmentStatusType.Completed;
            entity.CompletedAt = DateTime.UtcNow;
            entity.CompletedById = _currentUserService.UserId;

            await _context.SaveChangesAsync();
        }

        private void ValidateAppointmentAccess(Appointment appointment)
        {
            if (_currentUserService.Role == Roles.Admin)
                return;

            if (_currentUserService.Role == Roles.Client &&
                appointment.ClientId == _currentUserService.UserId)
                return;

            if (_currentUserService.Role == Roles.Barber &&
                appointment.BarberId == _currentUserService.UserId)
                return;

            throw new UnauthorizedException("You are not allowed to access this appointment.");
        }

        private void ValidateAppointmentManagementAccess(Appointment appointment)
        {
            if (_currentUserService.Role == Roles.Admin)
                return;

            if (_currentUserService.Role == Roles.Barber &&
                appointment.BarberId == _currentUserService.UserId)
                return;

            throw new UnauthorizedException("You are not allowed to manage this appointment.");
        }

        private static bool IsOverlapping(DateTime start, DateTime end, DateTime existingStart, DateTime existingEnd)
        {
            return start < existingEnd && end > existingStart;
        }

        private async Task ValidateBarberWorkingHours(int barberId, DateTime startDateTime, DateTime endDateTime)
        {
            var dayOfWeek = (int)startDateTime.DayOfWeek;
            var startTime = startDateTime.TimeOfDay;
            var endTime = endDateTime.TimeOfDay;

            var isWithinWorkingHours = await _context.WorkingHours.AnyAsync(x =>
                x.BarberId == barberId &&
                x.DayOfWeek == dayOfWeek &&
                x.IsWorking &&
                x.StartTime <= startTime &&
                x.EndTime >= endTime);

            if (!isWithinWorkingHours)
                throw new BusinessException("Barber is not working at the selected time.");
        }
    }
}