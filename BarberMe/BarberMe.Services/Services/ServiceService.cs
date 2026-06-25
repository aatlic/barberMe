using AutoMapper;
using BarberMe.Database.Context;
using BarberMe.Database.Models;
using BarberMe.Model.Requests.Service;
using BarberMe.Model.Responses;
using BarberMe.Model.Responses.Service;
using BarberMe.Model.SearchObjects;
using BarberMe.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace BarberMe.Services.Services
{
    public class ServiceService : IServiceService
    {
        private readonly BarberMeDbContext _context;
        private readonly IMapper _mapper;

        public ServiceService(BarberMeDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<PagedResponse<ServiceResponse>> GetAsync(ServiceSearchObject search)
        {
            var query = _context.Services.AsQueryable();

            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                query = query.Where(x =>
                    x.Name.Contains(search.FTS));
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(x =>
                    x.IsActive == search.IsActive.Value);
            }

            var totalCount = await query.CountAsync();

            var page = search.Page ?? 1;
            var pageSize = search.PageSize ?? 10;

            var list = await query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return new PagedResponse<ServiceResponse>
            {
                Items = _mapper.Map<List<ServiceResponse>>(list),
                TotalCount = totalCount,
                Page = page,
                PageSize = pageSize
            };
        }

        public async Task<ServiceResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Services.FindAsync(id);

            return entity == null ? null : _mapper.Map<ServiceResponse>(entity);
        }

        public async Task<ServiceResponse> InsertAsync(ServiceInsertRequest request)
        {
            var entity = _mapper.Map<Service>(request);

            _context.Services.Add(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<ServiceResponse>(entity);
        }

        public async Task<ServiceResponse?> UpdateAsync(int id, ServiceUpdateRequest request)
        {
            var entity = await _context.Services.FindAsync(id);

            if (entity == null)
                return null;

            _mapper.Map(request, entity);

            await _context.SaveChangesAsync();

            return _mapper.Map<ServiceResponse>(entity);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var entity = await _context.Services.FindAsync(id);

            if (entity == null)
                return false;

            _context.Services.Remove(entity);
            await _context.SaveChangesAsync();

            return true;
        }
    }
}
