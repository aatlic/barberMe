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
    public class NewsService : INewsService
    {
        private readonly BarberMeDbContext _context;
        private readonly IMapper _mapper;

        public NewsService(BarberMeDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<PagedResponse<NewsResponse>> GetAsync(NewsSearchObject search)
        {
            var query = _context.News.AsQueryable();

            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                query = query.Where(x =>
                    x.Title.Contains(search.FTS) ||
                    x.Content.Contains(search.FTS));
            }

            var totalCount = await query.CountAsync();

            var page = search.Page ?? 1;
            var pageSize = search.PageSize ?? 10;

            var list = await query
                .OrderByDescending(x => x.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return new PagedResponse<NewsResponse>
            {
                Items = _mapper.Map<List<NewsResponse>>(list),
                TotalCount = totalCount,
                Page = page,
                PageSize = pageSize
            };
        }

        public async Task<NewsResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.News
                .FirstOrDefaultAsync(x => x.NewsId == id);

            return entity == null ? null : _mapper.Map<NewsResponse>(entity);
        }

        public async Task<NewsResponse> InsertAsync(NewsInsertRequest request)
        {
            var entity = _mapper.Map<News>(request);

            _context.News.Add(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<NewsResponse>(entity);
        }

        public async Task<NewsResponse?> UpdateAsync(int id, NewsUpdateRequest request)
        {
            var entity = await _context.News
                .FirstOrDefaultAsync(x => x.NewsId == id);

            if (entity == null)
                return null;

            _mapper.Map(request, entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<NewsResponse>(entity);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var entity = await _context.News
                .FirstOrDefaultAsync(x => x.NewsId == id);

            if (entity == null)
                return false;

            _context.News.Remove(entity);
            await _context.SaveChangesAsync();

            return true;
        }
    }
}
