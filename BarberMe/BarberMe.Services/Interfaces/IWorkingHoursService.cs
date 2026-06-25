using BarberMe.Model.Requests.WorkingHours;
using BarberMe.Model.Responses.Service;
using BarberMe.Model.SearchObjects;

namespace BarberMe.Services.Interfaces
{
    public interface IWorkingHoursService :
                    ICRUDService<
                    WorkingHoursResponse,
                    WorkingHoursSearchObject,
                    WorkingHoursInsertRequest,
                    WorkingHoursUpdateRequest>
    {
        Task<List<WorkingHoursResponse>> GetByBarberAsync(int barberId);
    }
}
