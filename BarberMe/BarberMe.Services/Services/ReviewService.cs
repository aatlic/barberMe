using AutoMapper;
using BarberMe.Database.Context;
using BarberMe.Database.Models;
using BarberMe.Model.Constants;
using BarberMe.Model.Exceptions;
using BarberMe.Model.Requests.Review;
using BarberMe.Model.Responses;
using BarberMe.Model.Responses.Appointment;
using BarberMe.Model.SearchObjects;
using BarberMe.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace BarberMe.Services.Services
{
    public class ReviewService : IReviewService
    {
        private readonly BarberMeDbContext _context;
        private readonly IMapper _mapper;
        private readonly ICurrentUserService _currentUserService;

        public ReviewService(
            BarberMeDbContext context,
            IMapper mapper,
            ICurrentUserService currentUserService)
        {
            _context = context;
            _mapper = mapper;
            _currentUserService = currentUserService;
        }

        public async Task<PagedResponse<ReviewResponse>> GetAsync(ReviewSearchObject search)
        {
            var query = _context.Reviews
                .Include(x => x.Client)
                .Include(x => x.Barber)
                .Include(x => x.Appointment)
                .AsQueryable();

            if (_currentUserService.Role == Roles.Client)
            {
                query = query.Where(x => x.ClientId == _currentUserService.UserId);
            }
            else if (_currentUserService.Role == Roles.Barber)
            {
                query = query.Where(x => x.BarberId == _currentUserService.UserId);
            }
            else
            {
                if (search.ClientId.HasValue)
                    query = query.Where(x => x.ClientId == search.ClientId.Value);

                if (search.BarberId.HasValue)
                    query = query.Where(x => x.BarberId == search.BarberId.Value);
            }

            if (search.Rating.HasValue)
                query = query.Where(x => x.Rating == search.Rating.Value);

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

            return new PagedResponse<ReviewResponse>
            {
                Items = _mapper.Map<List<ReviewResponse>>(list),
                TotalCount = totalCount,
                Page = page,
                PageSize = pageSize
            };
        }

        public async Task<ReviewResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Reviews
                .Include(x => x.Client)
                .Include(x => x.Barber)
                .Include(x => x.Appointment)
                .FirstOrDefaultAsync(x => x.ReviewId == id);

            if (entity == null)
                throw new NotFoundException("Review does not exist.");

            return _mapper.Map<ReviewResponse>(entity);
        }

        public async Task<ReviewResponse> InsertAsync(ReviewInsertRequest request)
        {
            if (request.AppointmentId <= 0)
                throw new BusinessException("Appointment is required.");

            if (request.Rating < 1 || request.Rating > 5)
                throw new BusinessException("Rating must be between 1 and 5.");

            var appointment = await _context.Appointments
                .FirstOrDefaultAsync(x => x.AppointmentId == request.AppointmentId);

            if (appointment == null)
                throw new NotFoundException("Appointment does not exist.");

            if (_currentUserService.Role == Roles.Client &&
                appointment.ClientId != _currentUserService.UserId)
            {
                throw new UnauthorizedException("You are not allowed to review this appointment.");
            }

            if (appointment.CompletedAt == null)
                throw new BusinessException("You can review only completed appointments.");

            var reviewExists = await _context.Reviews
                .AnyAsync(x => x.AppointmentId == request.AppointmentId);

            if (reviewExists)
                throw new BusinessException("Review already exists for this appointment.");

            var entity = _mapper.Map<Review>(request);

            entity.ClientId = appointment.ClientId;
            entity.BarberId = appointment.BarberId;

            _context.Reviews.Add(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<ReviewResponse>(entity);
        }
    }
}
