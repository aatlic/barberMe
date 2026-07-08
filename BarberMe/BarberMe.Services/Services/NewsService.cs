using AutoMapper;
using BarberMe.Database.Context;
using BarberMe.Database.Models;
using BarberMe.Model.Exceptions;
using BarberMe.Model.Requests.Notification;
using BarberMe.Model.Responses;
using BarberMe.Model.Responses.Notification;
using BarberMe.Model.SearchObjects;
using BarberMe.Services.Helpers;
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

            if (entity == null)
                throw new NotFoundException("News does not exist.");

            return _mapper.Map<NewsResponse>(entity);
        }

        public async Task<NewsResponse> InsertAsync(NewsInsertRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Title))
                throw new BusinessException("News title is required.");

            if (string.IsNullOrWhiteSpace(request.Content))
                throw new BusinessException("News content is required.");

            ImageValidator.Validate(request.Image);

            var entity = _mapper.Map<News>(request);

            entity.Image = await ImageStorageHelper.SaveImageAsync(
                request.Image,
                "news");

            entity.IsActive = true;
            entity.CreatedAt = DateTime.UtcNow;

            _context.News.Add(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<NewsResponse>(entity);
        }

        public async Task<NewsResponse?> UpdateAsync(int id, NewsUpdateRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Title))
                throw new BusinessException("News title is required.");

            if (string.IsNullOrWhiteSpace(request.Content))
                throw new BusinessException("News content is required.");

            var entity = await _context.News
                .FirstOrDefaultAsync(x => x.NewsId == id);

            if (entity == null)
                throw new NotFoundException("News does not exist.");

            _mapper.Map(request, entity);

            if (request.Image != null)
            {
                ImageValidator.Validate(request.Image);

                ImageStorageHelper.DeleteImageIfExists(entity.Image);

                entity.Image = await ImageStorageHelper.SaveImageAsync(
                    request.Image,
                    "news");
            }

            await _context.SaveChangesAsync();

            return _mapper.Map<NewsResponse>(entity);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var entity = await _context.News
                .FirstOrDefaultAsync(x => x.NewsId == id);

            if (entity == null)
                throw new NotFoundException("News does not exist.");

            if (!entity.IsActive)
                throw new BusinessException("News is already inactive.");

            entity.IsActive = false;

            await _context.SaveChangesAsync();

            return true;
        }
    }
}
