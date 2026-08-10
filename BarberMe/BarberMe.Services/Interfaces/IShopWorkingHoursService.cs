using BarberMe.Model.Requests.ShopWorkingHours;
using BarberMe.Model.Responses;

namespace BarberMe.Services.Interfaces
{
    public interface IShopWorkingHoursService
    {
        Task<List<ShopWorkingHoursResponse>> GetAsync();

        Task<ShopWorkingHoursResponse> UpdateAsync(
            int id,
            ShopWorkingHoursUpdateRequest request);
    }
}