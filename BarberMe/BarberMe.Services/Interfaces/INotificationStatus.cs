using BarberMe.API.Interfaces;
using BarberMe.Model.Requests.Notification;
using BarberMe.Model.Responses.Notification;
using BarberMe.Model.SearchObjects;

namespace BarberMe.Services.Interfaces
{
    public interface INotificationStatus :
                    IService<
                    NotificationResponse,
                    NotificationSearchObject>
    {
        Task<NotificationResponse> Insert(NotificationInsertRequest request);

        Task MarkAsRead(int id);

        Task<int> GetUnreadCount(int userId);
    }
}
