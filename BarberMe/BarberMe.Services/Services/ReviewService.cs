using AutoMapper;
using BarberMe.Database.Context;
using BarberMe.Database.Models;
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

        public ReviewService(BarberMeDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<PagedResponse<ReviewResponse>> GetAsync(ReviewSearchObject search)
        {
            var query = _context.Reviews
                .Include(x => x.Client)
                .Include(x => x.Barber)
                .Include(x => x.Appointment)
                .AsQueryable();

            if (search.ClientId.HasValue)
                query = query.Where(x => x.ClientId == search.ClientId.Value);

            if (search.BarberId.HasValue)
                query = query.Where(x => x.BarberId == search.BarberId.Value);

            if (search.Rating.HasValue)
                query = query.Where(x => x.Rating == search.Rating.Value);

            var totalCount = await query.CountAsync();

            var page = search.Page ?? 1;
            var pageSize = search.PageSize ?? 10;

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

            return entity == null ? null : _mapper.Map<ReviewResponse>(entity);
        }

        public async Task<ReviewResponse> InsertAsync(ReviewInsertRequest request)
        {
            var entity = _mapper.Map<Review>(request);

            _context.Reviews.Add(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<ReviewResponse>(entity);
        }
    }
}
