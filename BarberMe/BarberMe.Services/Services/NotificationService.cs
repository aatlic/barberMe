using AutoMapper;
using BarberMe.Database.Context;
using BarberMe.Database.Models;
using BarberMe.Model.Requests.Notification;
using BarberMe.Model.Responses;
using BarberMe.Model.Responses.Notification;
using BarberMe.Model.SearchObjects;
using BarberMe.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace BarberMe.Services.Services
{
    public class NotificationService : INotificationService
    {
        private readonly BarberMeDbContext _context;
        private readonly IMapper _mapper;

        public NotificationService(BarberMeDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<PagedResponse<NotificationResponse>> GetAsync(NotificationSearchObject search)
        {
            var query = _context.Notifications
                .Include(x => x.User)
                .Include(x => x.NotificationType)
                .AsQueryable();

            if (search.UserId.HasValue)
                query = query.Where(x => x.UserId == search.UserId.Value);

            if (search.IsRead.HasValue)
                query = query.Where(x => x.IsRead == search.IsRead.Value);

            var totalCount = await query.CountAsync();

            var page = search.Page ?? 1;
            var pageSize = search.PageSize ?? 10;

            var list = await query
                .OrderByDescending(x => x.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return new PagedResponse<NotificationResponse>
            {
                Items = _mapper.Map<List<NotificationResponse>>(list),
                TotalCount = totalCount,
                Page = page,
                PageSize = pageSize
            };
        }

        public async Task<NotificationResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Notifications
                .Include(x => x.User)
                .Include(x => x.NotificationType)
                .FirstOrDefaultAsync(x => x.NotificationId == id);

            return entity == null ? null : _mapper.Map<NotificationResponse>(entity);
        }

        public async Task<NotificationResponse> InsertAsync(NotificationInsertRequest request)
        {
            var entity = _mapper.Map<Notification>(request);

            _context.Notifications.Add(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<NotificationResponse>(entity);
        }

        public async Task MarkAsRead(int id)
        {
            var entity = await _context.Notifications
                .FirstOrDefaultAsync(x => x.NotificationId == id);

            if (entity == null)
                return;

            entity.IsRead = true;

            await _context.SaveChangesAsync();
        }

        public async Task<int> GetUnreadCount(int userId)
        {
            return await _context.Notifications
                .CountAsync(x => x.UserId == userId && !x.IsRead);
        }
    }
}
