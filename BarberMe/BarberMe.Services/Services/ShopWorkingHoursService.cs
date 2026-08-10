using BarberMe.Database.Context;
using BarberMe.Model.Exceptions;
using BarberMe.Model.Requests.ShopWorkingHours;
using BarberMe.Model.Responses;
using BarberMe.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;

namespace BarberMe.Services
{
    public class ShopWorkingHoursService : IShopWorkingHoursService
    {
        private readonly BarberMeDbContext _context;
        private readonly IMemoryCache _cache;

        private const string CacheKey = "shop_working_hours";

        public ShopWorkingHoursService(
            BarberMeDbContext context,
            IMemoryCache cache)
        {
            _context = context;
            _cache = cache;
        }

        public async Task<List<ShopWorkingHoursResponse>> GetAsync()
        {
            if (_cache.TryGetValue(
                    CacheKey,
                    out List<ShopWorkingHoursResponse>? cachedHours)
                && cachedHours != null)
            {
                return cachedHours;
            }

            var entities = await _context.ShopWorkingHours
                .AsNoTracking()
                .OrderBy(x => x.DayOfWeek == 0 ? 7 : x.DayOfWeek)
                .ToListAsync();

            var result = entities
                .Select(x => new ShopWorkingHoursResponse
                {
                    Id = x.ShopWorkingHoursId,
                    DayOfWeek = x.DayOfWeek,
                    StartTime = x.StartTime,
                    EndTime = x.EndTime,
                    IsWorking = x.IsWorking
                })
                .ToList();

            _cache.Set(
                CacheKey,
                result,
                TimeSpan.FromMinutes(30));

            return result;
        }

        public async Task<ShopWorkingHoursResponse> UpdateAsync(
            int id,
            ShopWorkingHoursUpdateRequest request)
        {
            var entity = await _context.ShopWorkingHours
                .FirstOrDefaultAsync(x => x.ShopWorkingHoursId == id);

            if (entity == null)
            {
                throw new NotFoundException(
                    "Shop working hours were not found.");
            }

            if (request.IsWorking &&
                request.StartTime >= request.EndTime)
            {
                throw new BusinessException(
                    "Start time must be earlier than end time.");
            }

            var duplicateDayExists = await _context.ShopWorkingHours
                .AnyAsync(x =>
                    x.ShopWorkingHoursId != id &&
                    x.DayOfWeek == request.DayOfWeek);

            if (duplicateDayExists)
            {
                throw new BusinessException(
                    "Working hours for this day already exist.");
            }

            entity.DayOfWeek = request.DayOfWeek;
            entity.StartTime = request.StartTime;
            entity.EndTime = request.EndTime;
            entity.IsWorking = request.IsWorking;

            await _context.SaveChangesAsync();

            _cache.Remove(CacheKey);

            return new ShopWorkingHoursResponse
            {
                Id = entity.ShopWorkingHoursId,
                DayOfWeek = entity.DayOfWeek,
                StartTime = entity.StartTime,
                EndTime = entity.EndTime,
                IsWorking = entity.IsWorking
            };
        }
    }
}