using AutoMapper;
using BarberMe.Database.Models;
using BarberMe.Model.Responses.Appointment;
using BarberMe.Model.Responses.Notification;
using BarberMe.Model.Responses.Payment;
using BarberMe.Model.Responses.Recommendation;
using BarberMe.Model.Responses.Service;
using BarberMe.Model.Responses.Support;
using BarberMe.Model.Responses.User;
using BarberMe.Model.Requests.Appointment;
using BarberMe.Model.Requests.BarberLevel;
using BarberMe.Model.Requests.BarberService;
using BarberMe.Model.Requests.Notification;
using BarberMe.Model.Requests.RecommendationFeedback;
using BarberMe.Model.Requests.Refund;
using BarberMe.Model.Requests.Review;
using BarberMe.Model.Requests.Service;
using BarberMe.Model.Requests.Support;
using BarberMe.Model.Requests.User;
using BarberMe.Model.Requests.WorkingHours;

namespace BarberMe.API.Mapping
{
    public class MapperProfile : Profile
    {
        public MapperProfile()
        {
            CreateMap<User, UserResponse>()
                .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.UserId));

            CreateMap<Role, RoleResponse>()
                .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.RoleId));

            CreateMap<BarberLevel, BarberLevelResponse>()
                .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.BarberLevelId));

            CreateMap<Service, ServiceResponse>()
                .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.ServiceId));

            CreateMap<BarberService, BarberServiceResponse>()
                .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.BarberServiceId));

            CreateMap<WorkingHours, WorkingHoursResponse>()
                .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.WorkingHoursId));

            CreateMap<Appointment, AppointmentResponse>()
                .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.AppointmentId));

            CreateMap<Notification, NotificationResponse>()
                .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.NotificationId));

            CreateMap<Refund, RefundResponse>()
                .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.RefundId));

            CreateMap<Review, ReviewResponse>()
                .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.ReviewId));

            CreateMap<SupportRequest, SupportRequestResponse>()
                .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.SupportRequestId));

            CreateMap<Payment, PaymentResponse>()
                .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.PaymentId));

            CreateMap<News, NewsResponse>()
                .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.NewsId));

            CreateMap<Recommendation, RecommendationResponse>()
                .ForMember(dest => dest.RecommendationId, opt => opt.MapFrom(src => src.RecommendationId));

            CreateMap<RecommendationFeedback, RecommendationFeedbackResponse>()
                .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.RecommendationFeedbackId));

            CreateMap<UserInsertRequest, User>();
            CreateMap<UserUpdateRequest, User>();

            CreateMap<ServiceInsertRequest, Service>()
                .ForMember(dest => dest.ImageUrl, opt => opt.Ignore());

            CreateMap<ServiceUpdateRequest, Service>()
                .ForMember(dest => dest.ImageUrl, opt => opt.Ignore());

            CreateMap<NewsInsertRequest, News>()
                .ForMember(dest => dest.Image, opt => opt.Ignore());

            CreateMap<NewsUpdateRequest, News>()
                .ForMember(dest => dest.Image, opt => opt.Ignore());

            CreateMap<BarberServiceInsertRequest, BarberService>();
            CreateMap<BarberServiceUpdateRequest, BarberService>();

            CreateMap<WorkingHoursInsertRequest, WorkingHours>();
            CreateMap<WorkingHoursUpdateRequest, WorkingHours>();

            CreateMap<AppointmentInsertRequest, Appointment>();
            CreateMap<CancelAppointmentRequest, Appointment>();

            CreateMap<BarberLevelInsertRequest, BarberLevel>();
            CreateMap<BarberLevelUpdateRequest, BarberLevel>();

            CreateMap<NotificationInsertRequest, Notification>();

            CreateMap<RefundInsertRequest, Refund>();

            CreateMap<ReviewInsertRequest, Review>();

            CreateMap<SupportRequestInsertRequest, SupportRequest>();

            CreateMap<RecommendationFeedbackInsertRequest, RecommendationFeedback>();
        }
    }
}
