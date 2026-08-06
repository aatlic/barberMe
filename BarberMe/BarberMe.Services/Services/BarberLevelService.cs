using AutoMapper;
using BarberMe.Database.Context;
using BarberMe.Database.Models;
using BarberMe.Model.Exceptions;
using BarberMe.Model.Requests.BarberLevel;
using BarberMe.Model.Responses;
using BarberMe.Model.Responses.User;
using BarberMe.Model.SearchObjects;
using BarberMe.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;

namespace BarberMe.Services.Services
{
    public class BarberLevelService : IBarberLevelService
    {
        private readonly BarberMeDbContext _context;
        private readonly IMapper _mapper;
        private const string BarberLevelsCacheKey = "barber-levels";

        private readonly IMemoryCache _cache;
        public BarberLevelService(
            BarberMeDbContext context,
            IMapper mapper,
            IMemoryCache cache)
        {
            _context = context;
            _mapper = mapper;
            _cache = cache;
        }

        public async Task<PagedResponse<BarberLevelResponse>> GetAsync(BarberLevelSearchObject search)
        {
            if (string.IsNullOrWhiteSpace(search.FTS)
                && (search.Page ?? 1) == 1
                && (search.PageSize ?? 10) == 10)
            {
                if (_cache.TryGetValue(
                    BarberLevelsCacheKey,
                    out PagedResponse<BarberLevelResponse>? cached))
                {
                    return cached!;
                }
            }

            var query = _context.BarberLevels.AsQueryable();

            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                query = query.Where(x =>
                    x.Name.Contains(search.FTS));
            }

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
                .OrderBy(x => x.Name)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            var response = new PagedResponse<BarberLevelResponse>
            {
                Items = _mapper.Map<List<BarberLevelResponse>>(list),
                TotalCount = totalCount,
                Page = page,
                PageSize = pageSize
            };

            if (string.IsNullOrWhiteSpace(search.FTS)
                && page == 1
                && pageSize == 10)
            {
                _cache.Set(
                    BarberLevelsCacheKey,
                    response,
                    TimeSpan.FromMinutes(10));
            }

            return response;
        }

        public async Task<BarberLevelResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.BarberLevels
                .FirstOrDefaultAsync(x => x.BarberLevelId == id);

            if (entity == null)
                throw new NotFoundException("Barber level does not exist.");

            return _mapper.Map<BarberLevelResponse>(entity);
        }

        public async Task<BarberLevelResponse> InsertAsync(BarberLevelInsertRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Name))
                throw new BusinessException("Barber level name is required.");

            var exists = await _context.BarberLevels
                .AnyAsync(x => x.Name == request.Name);

            if (exists)
                throw new BusinessException("Barber level with this name already exists.");

            var entity = _mapper.Map<BarberLevel>(request);
            entity.IsActive = true;

            _context.BarberLevels.Add(entity);
            await _context.SaveChangesAsync();

            _cache.Remove(BarberLevelsCacheKey);

            return _mapper.Map<BarberLevelResponse>(entity);
        }

        public async Task<BarberLevelResponse?> UpdateAsync(int id, BarberLevelUpdateRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Name))
                throw new BusinessException("Barber level name is required.");

            var entity = await _context.BarberLevels
                .FirstOrDefaultAsync(x => x.BarberLevelId == id);

            if (entity == null)
                throw new NotFoundException("Barber level does not exist.");

            var exists = await _context.BarberLevels
                .AnyAsync(x => x.Name == request.Name && x.BarberLevelId != id);

            if (exists)
                throw new BusinessException("Barber level with this name already exists.");

            _mapper.Map(request, entity);
            await _context.SaveChangesAsync();

            _cache.Remove(BarberLevelsCacheKey);

            return _mapper.Map<BarberLevelResponse>(entity);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var entity = await _context.BarberLevels
                .FirstOrDefaultAsync(x => x.BarberLevelId == id);

            if (entity == null)
                throw new NotFoundException("Barber level does not exist.");

            if (!entity.IsActive)
                throw new BusinessException("Barber level is already inactive.");

            entity.IsActive = false;

            await _context.SaveChangesAsync();

            _cache.Remove(BarberLevelsCacheKey);

            return true;
        }
    }
}
