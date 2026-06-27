using AutoMapper;
using BarberMe.Database.Context;
using BarberMe.Model.Exceptions;
using BarberMe.Model.Responses;
using BarberMe.Model.Responses.User;
using BarberMe.Model.SearchObjects;
using BarberMe.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace BarberMe.Services.Services
{
    public class RoleService : IRoleService
    {
        private readonly BarberMeDbContext _context;
        private readonly IMapper _mapper;

        public RoleService(BarberMeDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<PagedResponse<RoleResponse>> GetAsync(BaseSearchObject search)
        {
            var query = _context.Roles.AsQueryable();

            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                query = query.Where(x => x.Name.Contains(search.FTS));
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

            return new PagedResponse<RoleResponse>
            {
                Items = _mapper.Map<List<RoleResponse>>(list),
                TotalCount = totalCount,
                Page = page,
                PageSize = pageSize
            };
        }

        public async Task<RoleResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Roles
                .FirstOrDefaultAsync(x => x.RoleId == id);

            if (entity == null)
                throw new NotFoundException("Role does not exist.");

            return _mapper.Map<RoleResponse>(entity);
        }
    }
}