using AutoMapper;
using BarberMe.Database.Context;
using BarberMe.Database.Models;
using BarberMe.Model.Requests.WorkingHours;
using BarberMe.Model.Responses;
using BarberMe.Model.Responses.Service;
using BarberMe.Model.SearchObjects;
using BarberMe.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using BarberMe.Model.Exceptions;

namespace BarberMe.Services.Services
{
    public class WorkingHoursService : IWorkingHoursService
    {
        private readonly BarberMeDbContext _context;
        private readonly IMapper _mapper;

        public WorkingHoursService(BarberMeDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<PagedResponse<WorkingHoursResponse>> GetAsync(WorkingHoursSearchObject search)
        {
            var query = _context.WorkingHours
                .Include(x => x.Barber)
                .AsQueryable();

            if (search.BarberId.HasValue)
                query = query.Where(x => x.BarberId == search.BarberId.Value);

            if (search.Day.HasValue)
                query = query.Where(x => x.DayOfWeek == (int)search.Day.Value);

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
                .OrderBy(x => x.DayOfWeek)
                .ThenBy(x => x.StartTime)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return new PagedResponse<WorkingHoursResponse>
            {
                Items = _mapper.Map<List<WorkingHoursResponse>>(list),
                TotalCount = totalCount,
                Page = page,
                PageSize = pageSize
            };
        }

        public async Task<WorkingHoursResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.WorkingHours
                .Include(x => x.Barber)
                .FirstOrDefaultAsync(x => x.WorkingHoursId == id);

            if (entity == null)
                throw new NotFoundException("Working hours do not exist.");

            return _mapper.Map<WorkingHoursResponse>(entity);
        }

        public async Task<WorkingHoursResponse> InsertAsync(WorkingHoursInsertRequest request)
        {
            if (request.BarberId <= 0)
                throw new BusinessException("Barber is required.");

            if (request.DayOfWeek < 0 || request.DayOfWeek > 6)
                throw new BusinessException("Day of week must be between 0 and 6.");

            if (request.StartTime >= request.EndTime)
                throw new BusinessException("Start time must be before end time.");

            var barberExists = await _context.Users
                .AnyAsync(x => x.UserId == request.BarberId && x.IsActive);

            if (!barberExists)
                throw new NotFoundException("Barber does not exist.");

            var alreadyExists = await _context.WorkingHours
                .AnyAsync(x => x.BarberId == request.BarberId &&
                               x.DayOfWeek == request.DayOfWeek);

            if (alreadyExists)
                throw new BusinessException("Working hours already exist for this barber and day.");

            var entity = _mapper.Map<WorkingHours>(request);

            _context.WorkingHours.Add(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<WorkingHoursResponse>(entity);
        }

        public async Task<WorkingHoursResponse?> UpdateAsync(int id, WorkingHoursUpdateRequest request)
        {
            var entity = await _context.WorkingHours
                .FirstOrDefaultAsync(x => x.WorkingHoursId == id);

            if (entity == null)
                throw new NotFoundException("Working hours do not exist.");

            if (request.StartTime >= request.EndTime)
                throw new BusinessException("Start time must be before end time.");

            _mapper.Map(request, entity);

            await _context.SaveChangesAsync();

            return _mapper.Map<WorkingHoursResponse>(entity);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var entity = await _context.WorkingHours
                .FirstOrDefaultAsync(x => x.WorkingHoursId == id);

            if (entity == null)
                throw new NotFoundException("Working hours do not exist.");

            _context.WorkingHours.Remove(entity);
            await _context.SaveChangesAsync();

            return true;
        }

        public async Task<List<WorkingHoursResponse>> GetByBarberAsync(int barberId)
        {
            if (barberId <= 0)
                throw new BusinessException("Barber is required.");

            var barberExists = await _context.Users
                .AnyAsync(x => x.UserId == barberId && x.IsActive);

            if (!barberExists)
                throw new NotFoundException("Barber does not exist.");

            var list = await _context.WorkingHours
                .Where(x => x.BarberId == barberId)
                .OrderBy(x => x.DayOfWeek)
                .ToListAsync();

            return _mapper.Map<List<WorkingHoursResponse>>(list);
        }
    }
}
