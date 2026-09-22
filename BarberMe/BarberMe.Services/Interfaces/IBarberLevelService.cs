using BarberMe.Model.Requests.BarberLevel;
using BarberMe.Model.Responses.User;
using BarberMe.Model.SearchObjects;

namespace BarberMe.Services.Interfaces
{
    public interface IBarberLevelService :
                    ICRUDService<
                    BarberLevelResponse,
                    BarberLevelSearchObject,
                    BarberLevelInsertRequest,
                    BarberLevelUpdateRequest>
    {
        Task<bool> ActivateAsync(int id);
        Task<bool> DeactivateAsync(int id);
    }
}
