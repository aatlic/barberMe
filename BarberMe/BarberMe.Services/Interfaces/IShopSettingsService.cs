using BarberMe.Model.Requests.ShopSettings;
using BarberMe.Model.Responses;

namespace BarberMe.Services.Interfaces
{
    public interface IShopSettingsService
    {
        Task<ShopSettingsResponse> GetAsync();

        Task<ShopSettingsResponse> UpdateAsync(
            ShopSettingsUpdateRequest request);
    }
}