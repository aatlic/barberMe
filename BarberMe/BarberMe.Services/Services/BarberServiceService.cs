using AutoMapper;
using BarberMe.Database.Context;
using BarberMe.Database.Models;
using BarberMe.Model.Requests.BarberService;
using BarberMe.Model.Responses;
using BarberMe.Model.Responses.Service;
using BarberMe.Model.SearchObjects;
using BarberMe.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace BarberMe.Services.Services
{
    public class BarberServiceService : IBarberService
    {
        private readonly BarberMeDbContext _context;
        private readonly IMapper _mapper;

        public BarberServiceService(
            BarberMeDbContext context,
            IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<PagedResponse<BarberServiceResponse>> GetAsync(
            BarberServiceSearchObject search)
        {
            var query = _context.BarberServices
                .Include(x => x.Barber)
                .Include(x => x.Service)
                .AsQueryable();

            if (search.BarberId.HasValue)
                query = query.Where(x => x.BarberId == search.BarberId);

            if (search.ServiceId.HasValue)
                query = query.Where(x => x.ServiceId == search.ServiceId);

            var totalCount = await query.CountAsync();

            var page = search.Page ?? 1;
            var pageSize = search.PageSize ?? 10;

            var list = await query
                .OrderBy(x => x.BarberId)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return new PagedResponse<BarberServiceResponse>
            {
                Items = _mapper.Map<List<BarberServiceResponse>>(list),
                TotalCount = totalCount,
                Page = page,
                PageSize = pageSize
            };
        }

        public async Task<BarberServiceResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.BarberServices
                .Include(x => x.Barber)
                .Include(x => x.Service)
                .FirstOrDefaultAsync(x => x.BarberServiceId == id);

            return entity == null
                ? null
                : _mapper.Map<BarberServiceResponse>(entity);
        }

        public async Task<BarberServiceResponse> InsertAsync(
            BarberServiceInsertRequest request)
        {
            var entity = _mapper.Map<BarberService>(request);

            _context.BarberServices.Add(entity);

            await _context.SaveChangesAsync();

            return _mapper.Map<BarberServiceResponse>(entity);
        }

        public async Task<BarberServiceResponse?> UpdateAsync(
            int id,
            BarberServiceUpdateRequest request)
        {
            var entity = await _context.BarberServices
                .FirstOrDefaultAsync(x => x.BarberServiceId == id);

            if (entity == null)
                return null;

            _mapper.Map(request, entity);

            await _context.SaveChangesAsync();

            return _mapper.Map<BarberServiceResponse>(entity);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var entity = await _context.BarberServices
                .FirstOrDefaultAsync(x => x.BarberServiceId == id);

            if (entity == null)
                return false;

            _context.BarberServices.Remove(entity);

            await _context.SaveChangesAsync();

            return true;
        }
    }
}