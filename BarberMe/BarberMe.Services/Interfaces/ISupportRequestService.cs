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
        Task<SupportRequestResponse> InsertAsync(SupportRequestInsertRequest request);

        Task ResolveAsync(int id);
    }
}
