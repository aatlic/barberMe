using BarberMe.API.Interfaces;
using BarberMe.Model.Requests.Review;
using BarberMe.Model.Responses.Appointment;
using BarberMe.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BarberMe.Services.Interfaces
{
    public interface IReviewService :
                    IService<
                    ReviewResponse,
                    ReviewSearchObject>
    {
        Task<ReviewResponse>
        Insert(ReviewInsertRequest request);
    }
}
