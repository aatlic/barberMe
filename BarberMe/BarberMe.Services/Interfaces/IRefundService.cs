using BarberMe.Model.Requests.Refund;
using BarberMe.Model.Responses.Payment;

namespace BarberMe.Services.Interfaces
{
    public interface IRefundService
    {
        Task<RefundResponse> Insert(RefundInsertRequest request);
    }
}
