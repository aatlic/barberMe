using AutoMapper;
using BarberMe.Database.Models;
using BarberMe.Model.Requests.Appointment;
using BarberMe.Model.Requests.BarberLevel;
using BarberMe.Model.Requests.BarberService;
using BarberMe.Model.Requests.Notification;
using BarberMe.Model.Requests.Refund;
using BarberMe.Model.Requests.Review;
using BarberMe.Model.Requests.Service;
using BarberMe.Model.Requests.Support;
using BarberMe.Model.Requests.User;
using BarberMe.Model.Requests.WorkingHours;
using BarberMe.Model.Responses.Appointment;
using BarberMe.Model.Responses.Notification;
using BarberMe.Model.Responses.Payment;
using BarberMe.Model.Responses.Recommendation;
using BarberMe.Model.Responses.Service;
using BarberMe.Model.Responses.Support;
using BarberMe.Model.Responses.User;

namespace BarberMe.API.Mapping
{
    public class MapperProfile : Profile
    {
        public MapperProfile()
        {
            CreateMap<User, UserResponse>();
            CreateMap<UserInsertRequest, User>();
            CreateMap<UserUpdateRequest, User>();

            CreateMap<Role, RoleResponse>();

            CreateMap<BarberLevel, BarberLevelResponse>();

            CreateMap<Service, ServiceResponse>();
            CreateMap<ServiceInsertRequest, Service>();
            CreateMap<ServiceUpdateRequest, Service>();

            CreateMap<BarberService, BarberServiceResponse>();
            CreateMap<BarberServiceInsertRequest, BarberService>();

            CreateMap<WorkingHours, WorkingHoursResponse>();
            CreateMap<WorkingHoursInsertRequest, WorkingHours>();
            CreateMap<WorkingHoursUpdateRequest, WorkingHours>();

            CreateMap<Appointment, AppointmentResponse>();
            CreateMap<AppointmentInsertRequest, Appointment>();
            CreateMap<AppointmentUpdateRequest, Appointment>();

            CreateMap<BarberLevel, BarberLevelResponse>();
            CreateMap<BarberLevelInsertRequest, BarberLevel>();
            CreateMap<BarberLevelUpdateRequest, BarberLevel>();

            CreateMap<Notification, NotificationResponse>();
            CreateMap<NotificationInsertRequest, Notification>();

            CreateMap<Refund, RefundResponse>();
            CreateMap<RefundInsertRequest, Refund>();

            CreateMap<Review, ReviewResponse>();
            CreateMap<ReviewInsertRequest, Review>();

            CreateMap<SupportRequest, SupportRequestResponse>();
            CreateMap<SupportRequestInsertRequest, SupportRequest>();

            CreateMap<Payment, PaymentResponse>();

            CreateMap<News, NewsResponse>();
            CreateMap<NewsInsertRequest, News>();
            CreateMap<NewsUpdateRequest, News>();

            CreateMap<Recommendation, RecommendationResponse>();
            CreateMap<RecommendationFeedback, RecommendationFeedbackResponse>();
        }
    }
}
