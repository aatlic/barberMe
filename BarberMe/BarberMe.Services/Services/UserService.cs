using AutoMapper;
using BarberMe.Database.Context;
using BarberMe.Database.Models;
using BarberMe.Model.Requests.Auth;
using BarberMe.Model.Requests.User;
using BarberMe.Model.Responses;
using BarberMe.Model.Responses.Auth;
using BarberMe.Model.Responses.User;
using BarberMe.Model.SearchObjects;
using BarberMe.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
namespace BarberMe.Services.Services
{
    public class UserService : IUserService
    {
        private readonly BarberMeDbContext _context;
        private readonly IMapper _mapper;

        public UserService(BarberMeDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<PagedResponse<UserResponse>> GetAsync(UserSearchObject search)
        {
            var query = _context.Users
                .Include(x => x.Role)
                .Include(x => x.BarberLevel)
                .AsQueryable();

            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                query = query.Where(x =>
                    x.FirstName.Contains(search.FTS) ||
                    x.LastName.Contains(search.FTS) ||
                    x.Username.Contains(search.FTS) ||
                    x.Email.Contains(search.FTS));
            }

            if (search.RoleId.HasValue)
            {
                query = query.Where(x => x.RoleId == search.RoleId.Value);
            }

            var totalCount = await query.CountAsync();

            var page = search.Page ?? 1;
            var pageSize = search.PageSize ?? 10;

            var list = await query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return new PagedResponse<UserResponse>
            {
                Items = _mapper.Map<List<UserResponse>>(list),
                TotalCount = totalCount,
                Page = page,
                PageSize = pageSize
            };
        }

        public async Task<UserResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Users
                .Include(x => x.Role)
                .Include(x => x.BarberLevel)
                .FirstOrDefaultAsync(x => x.UserId == id);

            return entity == null ? null : _mapper.Map<UserResponse>(entity);
        }

        public async Task<UserResponse> InsertAsync(UserInsertRequest request)
        {
            var entity = _mapper.Map<User>(request);

            _context.Users.Add(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<UserResponse>(entity);
        }

        public async Task<UserResponse?> UpdateAsync(int id, UserUpdateRequest request)
        {
            var entity = await _context.Users.FindAsync(id);

            if (entity == null)
                return null;

            _mapper.Map(request, entity);

            await _context.SaveChangesAsync();

            return _mapper.Map<UserResponse>(entity);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var entity = await _context.Users.FindAsync(id);

            if (entity == null)
                return false;

            _context.Users.Remove(entity);
            await _context.SaveChangesAsync();

            return true;
        }

        public Task<LoginResponse> Login(LoginRequest request)
        {
            throw new NotImplementedException();
        }

        public Task ForgotPassword(ForgotPasswordRequest request)
        {
            throw new NotImplementedException();
        }

        public Task ResetPassword(ResetPasswordRequest request)
        {
            throw new NotImplementedException();
        }

        public Task ChangePassword(int userId, ChangePasswordRequest request)
        {
            throw new NotImplementedException();
        }

        public Task<string> UploadProfileImage(int userId, UploadProfileImageRequest request)
        {
            throw new NotImplementedException();
        }
    }
}
