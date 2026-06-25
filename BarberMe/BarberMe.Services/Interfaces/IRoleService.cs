using BarberMe.API.Interfaces;
using BarberMe.Model.Responses.User;
using BarberMe.Model.SearchObjects;

namespace BarberMe.Services.Interfaces
{
    public interface IRoleService :
                    IService<
                    RoleResponse,
                    BaseSearchObject>
    {
    }
}
