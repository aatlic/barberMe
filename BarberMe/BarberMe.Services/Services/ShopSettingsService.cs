using BarberMe.Database.Context;
using BarberMe.Model.Exceptions;
using BarberMe.Model.Requests.ShopSettings;
using BarberMe.Model.Responses;
using BarberMe.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;

namespace BarberMe.Services
{
    public class ShopSettingsService : IShopSettingsService
    {
        private readonly BarberMeDbContext _context;
        private readonly IMemoryCache _cache;
        private const string CacheKey = "shop_settings";

        public ShopSettingsService(
            BarberMeDbContext context,
            IMemoryCache cache)
        {
            _context = context;
            _cache = cache;
        }

        public async Task<ShopSettingsResponse> GetAsync()
        {
            if (_cache.TryGetValue(CacheKey, out ShopSettingsResponse? cachedSettings)
                && cachedSettings != null)
            {
                return cachedSettings;
            }

            var entity = await _context.ShopSettings
                .AsNoTracking()
                .FirstOrDefaultAsync();

            if (entity == null)
            {
                throw new NotFoundException("Shop settings were not found.");
            }

            var response = new ShopSettingsResponse
            {
                Id = entity.ShopSettingsId,
                Name = entity.Name,
                Address = entity.Address,
                PhoneNumber = entity.PhoneNumber,
                Email = entity.Email,
                Description = entity.Description
            };

            _cache.Set(
                CacheKey,
                response,
                TimeSpan.FromMinutes(30));

            return response;
        }

        public async Task<ShopSettingsResponse> UpdateAsync(
            ShopSettingsUpdateRequest request)
        {
            var entity = await _context.ShopSettings
                .FirstOrDefaultAsync();

            if (entity == null)
            {
                throw new NotFoundException("Shop settings were not found.");
            }

            entity.Name = request.Name.Trim();
            entity.Address = request.Address.Trim();
            entity.PhoneNumber = request.PhoneNumber.Trim();
            entity.Email = request.Email.Trim();
            entity.Description = string.IsNullOrWhiteSpace(request.Description)
                ? null
                : request.Description.Trim();

            await _context.SaveChangesAsync();

            _cache.Remove(CacheKey);

            return new ShopSettingsResponse
            {
                Id = entity.ShopSettingsId,
                Name = entity.Name,
                Address = entity.Address,
                PhoneNumber = entity.PhoneNumber,
                Email = entity.Email,
                Description = entity.Description
            };
        }
    }
}