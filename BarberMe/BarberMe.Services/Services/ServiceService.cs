using AutoMapper;
using BarberMe.Database.Context;
using BarberMe.Database.Models;
using BarberMe.Model.Requests.Service;
using BarberMe.Model.Responses;
using BarberMe.Model.Responses.Service;
using BarberMe.Model.SearchObjects;
using BarberMe.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using BarberMe.Model.Exceptions;

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
                .OrderBy(x => x.Name)
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

            if (entity == null)
                throw new NotFoundException("Service does not exist.");

            return _mapper.Map<ServiceResponse>(entity);
        }

        public async Task<ServiceResponse> InsertAsync(ServiceInsertRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Name))
                throw new BusinessException("Service name is required.");

            if (request.DefaultPrice <= 0)
                throw new BusinessException("Service price must be greater than zero.");

            if (request.DefaultDurationMinutes <= 0)
                throw new BusinessException("Service duration must be greater than zero.");

            if (request.DefaultDurationMinutes > 480)
                throw new BusinessException("Service duration cannot exceed 480 minutes.");

            var exists = await _context.Services
                .AnyAsync(x => x.Name == request.Name);

            if (exists)
                throw new BusinessException("Service with this name already exists.");

            var entity = _mapper.Map<Service>(request);

            entity.IsActive = true;

            _context.Services.Add(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<ServiceResponse>(entity);
        }

        public async Task<ServiceResponse?> UpdateAsync(int id, ServiceUpdateRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Name))
                throw new BusinessException("Service name is required.");

            if (request.DefaultPrice <= 0)
                throw new BusinessException("Service price must be greater than zero.");

            if (request.DefaultDurationMinutes <= 0)
                throw new BusinessException("Service duration must be greater than zero.");

            if (request.DefaultDurationMinutes > 480)
                throw new BusinessException("Service duration cannot exceed 480 minutes.");

            var entity = await _context.Services.FindAsync(id);

            if (entity == null)
                throw new NotFoundException("Service does not exist.");

            var exists = await _context.Services
                .AnyAsync(x => x.Name == request.Name && x.ServiceId != id);

            if (exists)
                throw new BusinessException("Service with this name already exists.");

            _mapper.Map(request, entity);

            await _context.SaveChangesAsync();

            return _mapper.Map<ServiceResponse>(entity);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var entity = await _context.Services.FindAsync(id);

            if (entity == null)
                throw new NotFoundException("Service does not exist.");

            if (!entity.IsActive)
                throw new BusinessException("Service is already inactive.");

            entity.IsActive = false;

            await _context.SaveChangesAsync();

            return true;
        }
    }
}
