using AutoMapper;
using BarberMe.Database.Context;
using BarberMe.Database.Models;
using BarberMe.Model.Requests.BarberLevel;
using BarberMe.Model.Responses;
using BarberMe.Model.Responses.User;
using BarberMe.Model.SearchObjects;
using BarberMe.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace BarberMe.Services.Services
{
    public class BarberLevelService : IBarberLevelService
    {
        private readonly BarberMeDbContext _context;
        private readonly IMapper _mapper;

        public BarberLevelService(
            BarberMeDbContext context,
            IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<PagedResponse<BarberLevelResponse>> GetAsync(BarberLevelSearchObject search)
        {
            var query = _context.BarberLevels.AsQueryable();

            if (!string.IsNullOrWhiteSpace(search.Name))
            {
                query = query.Where(x => x.Name.Contains(search.Name));
            }

            var totalCount = await query.CountAsync();

            var page = search.Page ?? 1;
            var pageSize = search.PageSize ?? 10;

            var list = await query
                .OrderBy(x => x.Name)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return new PagedResponse<BarberLevelResponse>
            {
                Items = _mapper.Map<List<BarberLevelResponse>>(list),
                TotalCount = totalCount,
                Page = page,
                PageSize = pageSize
            };
        }

        public async Task<BarberLevelResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.BarberLevels
                .FirstOrDefaultAsync(x => x.BarberLevelId == id);

            return entity == null
                ? null
                : _mapper.Map<BarberLevelResponse>(entity);
        }

        public async Task<BarberLevelResponse> InsertAsync(BarberLevelInsertRequest request)
        {
            var entity = _mapper.Map<BarberLevel>(request);

            _context.BarberLevels.Add(entity);

            await _context.SaveChangesAsync();

            return _mapper.Map<BarberLevelResponse>(entity);
        }

        public async Task<BarberLevelResponse?> UpdateAsync(int id, BarberLevelUpdateRequest request)
        {
            var entity = await _context.BarberLevels
                .FirstOrDefaultAsync(x => x.BarberLevelId == id);

            if (entity == null)
                return null;

            _mapper.Map(request, entity);

            await _context.SaveChangesAsync();

            return _mapper.Map<BarberLevelResponse>(entity);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var entity = await _context.BarberLevels
                .FirstOrDefaultAsync(x => x.BarberLevelId == id);

            if (entity == null)
                return false;

            _context.BarberLevels.Remove(entity);

            await _context.SaveChangesAsync();

            return true;
        }
    }
}
