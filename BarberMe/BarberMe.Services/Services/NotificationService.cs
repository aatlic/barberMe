using AutoMapper;
using BarberMe.Database.Context;
using BarberMe.Database.Models;
using BarberMe.Model.Exceptions;
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

            if (page < 1)
                page = 1;

            if (pageSize < 1)
                pageSize = 10;

            if (pageSize > 100)
                pageSize = 100;

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

            if (entity == null)
                throw new NotFoundException("Notification does not exist.");

            return _mapper.Map<NotificationResponse>(entity);
        }

        public async Task<NotificationResponse> InsertAsync(NotificationInsertRequest request)
        {
            if (request.UserId <= 0)
                throw new BusinessException("User is required.");

            if (request.NotificationTypeId <= 0)
                throw new BusinessException("Notification type is required.");

            if (string.IsNullOrWhiteSpace(request.Title))
                throw new BusinessException("Notification title is required.");

            if (string.IsNullOrWhiteSpace(request.Text))
                throw new BusinessException("Notification message is required.");

            var userExists = await _context.Users
                .AnyAsync(x => x.UserId == request.UserId && x.IsActive);

            if (!userExists)
                throw new NotFoundException("User does not exist.");

            var typeExists = await _context.NotificationTypes
                .AnyAsync(x => x.NotificationTypeId == request.NotificationTypeId);

            if (!typeExists)
                throw new NotFoundException("Notification type does not exist.");

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
                throw new NotFoundException("Notification does not exist.");

            if (entity.IsRead)
                throw new BusinessException("Notification is already marked as read.");

            entity.IsRead = true;

            await _context.SaveChangesAsync();
        }

        public async Task<int> GetUnreadCount(int userId)
        {
            var userExists = await _context.Users
                .AnyAsync(x => x.UserId == userId && x.IsActive);

            if (!userExists)
                throw new NotFoundException("User does not exist.");

            return await _context.Notifications
                .CountAsync(x => x.UserId == userId && !x.IsRead);
        }
    }
}
