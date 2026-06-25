using BarberMe.API.Interfaces;
using BarberMe.Model.Requests.Notification;
using BarberMe.Model.Responses.Notification;
using BarberMe.Model.SearchObjects;

namespace BarberMe.Services.Interfaces
{
    public interface INewsService :
                    ICRUDService<
                    NewsResponse,
                    NewsSearchObject,
                    NewsInsertRequest,
                    NewsUpdateRequest>
    {
    }
}
