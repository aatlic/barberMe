using BarberMe.API.Interfaces;
using BarberMe.Model.Requests.Support;
using BarberMe.Model.Responses.Support;
using BarberMe.Model.SearchObjects;

namespace BarberMe.Services.Interfaces
{
    public interface ISupportRequestService :
                    IService<
                    SupportRequestResponse,
                    SupportRequestSearchObject>
    {
        Task<SupportRequestResponse> Insert(SupportRequestInsertRequest request);

        Task Resolve(int id);
    }
}
