using AutoMapper;
using BarberMe.Database.Context;
using BarberMe.Database.Models;
using BarberMe.Model.Enum;
using BarberMe.Model.Exceptions;
using BarberMe.Model.Requests.Support;
using BarberMe.Model.Responses;
using BarberMe.Model.Responses.Support;
using BarberMe.Model.SearchObjects;
using BarberMe.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;

namespace BarberMe.Services.Services
{
    public class SupportRequestService: ISupportRequestService
    {
        private readonly BarberMeDbContext _context;
        private readonly IMapper _mapper;

        public SupportRequestService(BarberMeDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<PagedResponse<SupportRequestResponse>> GetAsync(SupportRequestSearchObject search)
        {
            var query = _context.SupportRequests
                .Include(x => x.User)
                .AsQueryable();

            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                query = query.Where(x =>
                    x.Subject.Contains(search.FTS) ||
                    x.Message.Contains(search.FTS));
            }

            if (search.Status.HasValue)
                query = query.Where(x => x.Status == search.Status.Value);

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

            return new PagedResponse<SupportRequestResponse>
            {
                Items = _mapper.Map<List<SupportRequestResponse>>(list),
                TotalCount = totalCount,
                Page = page,
                PageSize = pageSize
            };
        }

        public async Task<SupportRequestResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.SupportRequests
                .Include(x => x.User)
                .FirstOrDefaultAsync(x => x.SupportRequestId == id);

            if (entity == null)
                throw new NotFoundException("Support request does not exist.");

            return _mapper.Map<SupportRequestResponse>(entity);
        }

        public async Task<SupportRequestResponse> InsertAsync(SupportRequestInsertRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.FullName))
                throw new BusinessException("Full name is required.");

            if (string.IsNullOrWhiteSpace(request.Email))
                throw new BusinessException("Email is required.");

            if (!new EmailAddressAttribute().IsValid(request.Email))
                throw new BusinessException("Email address is not valid.");

            if (string.IsNullOrWhiteSpace(request.Subject))
                throw new BusinessException("Subject is required.");

            if (string.IsNullOrWhiteSpace(request.Message))
                throw new BusinessException("Message is required.");

            var entity = _mapper.Map<SupportRequest>(request);

            entity.Status = SupportRequestStatus.Open;
            entity.CreatedAt = DateTime.UtcNow;

            _context.SupportRequests.Add(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<SupportRequestResponse>(entity);
        }

        public async Task ResolveAsync(int id)
        {
            var entity = await _context.SupportRequests
                .FirstOrDefaultAsync(x => x.SupportRequestId == id);

            if (entity == null)
                throw new NotFoundException("Support request does not exist.");

            if (entity.Status == SupportRequestStatus.Closed)
                throw new BusinessException("Support request is already closed.");

            entity.Status = SupportRequestStatus.Closed;

            await _context.SaveChangesAsync();
        }
    }
}
