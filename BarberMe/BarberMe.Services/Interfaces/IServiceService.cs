using BarberMe.API.Interfaces;
using BarberMe.Model.Requests.Service;
using BarberMe.Model.Responses.Service;
using BarberMe.Model.SearchObjects;

namespace BarberMe.Services.Interfaces
{
    public interface IServiceService :
                    ICRUDService<
                    ServiceResponse,
                    ServiceSearchObject,
                    ServiceInsertRequest,
                    ServiceUpdateRequest>
    {
    }
}
