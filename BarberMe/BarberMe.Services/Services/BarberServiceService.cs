using AutoMapper;
using BarberMe.Database.Context;
using BarberMe.Database.Models;
using BarberMe.Model.Requests.BarberService;
using BarberMe.Model.Responses;
using BarberMe.Model.Responses.Service;
using BarberMe.Model.SearchObjects;
using BarberMe.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using BarberMe.Model.Exceptions;

namespace BarberMe.Services.Services
{
    public class BarberServiceService : IBarberService
    {
        private readonly BarberMeDbContext _context;
        private readonly IMapper _mapper;

        public BarberServiceService(
            BarberMeDbContext context,
            IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<PagedResponse<BarberServiceResponse>> GetAsync(
            BarberServiceSearchObject search)
        {
            var query = _context.BarberServices
                .Include(x => x.Barber)
                .Include(x => x.Service)
                .AsQueryable();

            if (search.BarberId.HasValue)
                query = query.Where(x => x.BarberId == search.BarberId);

            if (search.ServiceId.HasValue)
                query = query.Where(x => x.ServiceId == search.ServiceId);

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
                .OrderBy(x => x.BarberId)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return new PagedResponse<BarberServiceResponse>
            {
                Items = _mapper.Map<List<BarberServiceResponse>>(list),
                TotalCount = totalCount,
                Page = page,
                PageSize = pageSize
            };
        }

        public async Task<BarberServiceResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.BarberServices
                .Include(x => x.Barber)
                .Include(x => x.Service)
                .FirstOrDefaultAsync(x => x.BarberServiceId == id);

            if (entity == null)
                throw new NotFoundException("Barber service does not exist.");

            return entity == null
                ? null
                : _mapper.Map<BarberServiceResponse>(entity);
        }

        public async Task<BarberServiceResponse> InsertAsync(BarberServiceInsertRequest request)
        {
            if (request.BarberId <= 0)
                throw new BusinessException("Barber is required.");

            if (request.ServiceId <= 0)
                throw new BusinessException("Service is required.");

            if (request.Price <= 0)
                throw new BusinessException("Price must be greater than zero.");

            if (request.DurationMinutes <= 0)
                throw new BusinessException("Duration must be greater than zero.");

            var barberExists = await _context.Users
                .AnyAsync(x => x.UserId == request.BarberId && x.IsActive);

            if (!barberExists)
                throw new NotFoundException("Barber does not exist.");

            var serviceExists = await _context.Services
                .AnyAsync(x => x.ServiceId == request.ServiceId && x.IsActive);

            if (!serviceExists)
                throw new NotFoundException("Service does not exist.");

            var alreadyExists = await _context.BarberServices
                .AnyAsync(x => x.BarberId == request.BarberId &&
                               x.ServiceId == request.ServiceId);

            if (alreadyExists)
                throw new BusinessException("This service is already assigned to the barber.");

            var entity = _mapper.Map<BarberService>(request);

            _context.BarberServices.Add(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<BarberServiceResponse>(entity);
        }

        public async Task<BarberServiceResponse?> UpdateAsync(
            int id,
            BarberServiceUpdateRequest request)
        {
            if (request.Price <= 0)
                throw new BusinessException("Price must be greater than zero.");

            if (request.DurationMinutes <= 0)
                throw new BusinessException("Duration must be greater than zero.");

            var entity = await _context.BarberServices
                .FirstOrDefaultAsync(x => x.BarberServiceId == id);

            if (entity == null)
                throw new NotFoundException("Barber service does not exist.");

            _mapper.Map(request, entity);

            await _context.SaveChangesAsync();

            return _mapper.Map<BarberServiceResponse>(entity);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var entity = await _context.BarberServices
                .FirstOrDefaultAsync(x => x.BarberServiceId == id);

            if (entity == null)
                throw new NotFoundException("Barber service does not exist.");

            var hasAppointments = await _context.Appointments
                .AnyAsync(x => x.BarberServiceId == id);

            if (hasAppointments)
                throw new BusinessException("This barber service cannot be deleted because it is used in appointments.");

            _context.BarberServices.Remove(entity);

            await _context.SaveChangesAsync();

            return true;
        }
    }
}