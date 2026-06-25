using BarberMe.Model.Requests.Review;
using BarberMe.Model.Responses.Appointment;
using BarberMe.Model.SearchObjects;

namespace BarberMe.Services.Interfaces
{
    public interface IReviewService :
                    IService<
                    ReviewResponse,
                    ReviewSearchObject>
    {
        Task<ReviewResponse> InsertAsync(ReviewInsertRequest request);
    }
}
