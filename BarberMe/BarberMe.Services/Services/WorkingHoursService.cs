using AutoMapper;
using BarberMe.Database.Context;
using BarberMe.Database.Models;
using BarberMe.Model.Requests.WorkingHours;
using BarberMe.Model.Responses;
using BarberMe.Model.Responses.Service;
using BarberMe.Model.SearchObjects;
using BarberMe.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

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

            return entity == null ? null : _mapper.Map<WorkingHoursResponse>(entity);
        }

        public async Task<WorkingHoursResponse> InsertAsync(WorkingHoursInsertRequest request)
        {
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
                return null;

            _mapper.Map(request, entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<WorkingHoursResponse>(entity);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var entity = await _context.WorkingHours
                .FirstOrDefaultAsync(x => x.WorkingHoursId == id);

            if (entity == null)
                return false;

            _context.WorkingHours.Remove(entity);
            await _context.SaveChangesAsync();

            return true;
        }

        public async Task<List<WorkingHoursResponse>> GetByBarberAsync(int barberId)
        {
            var list = await _context.WorkingHours
                .Where(x => x.BarberId == barberId)
                .OrderBy(x => x.DayOfWeek)
                .ToListAsync();

            return _mapper.Map<List<WorkingHoursResponse>>(list);
        }
    }
}
