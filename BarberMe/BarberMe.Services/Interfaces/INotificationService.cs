using BarberMe.Model.Requests.Notification;
using BarberMe.Model.Responses.Notification;
using BarberMe.Model.SearchObjects;

namespace BarberMe.Services.Interfaces
{
    public interface INotificationService :
                    IService<
                    NotificationResponse,
                    NotificationSearchObject>
    {
        Task<NotificationResponse> InsertAsync(NotificationInsertRequest request);

        Task MarkAsRead(int id);

        Task<int> GetUnreadCount(int userId);
    }
}
