using BarberMe.Model.Requests.BarberService;
using BarberMe.Model.Responses.Service;
using BarberMe.Model.SearchObjects;

namespace BarberMe.Services.Interfaces
{
    public interface IBarberService :
                    ICRUDService<
                    BarberServiceResponse,
                    BarberServiceSearchObject,
                    BarberServiceInsertRequest,
                    BarberServiceUpdateRequest>
    {
    }
}
