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
        private readonly IJwtService _jwtService;

        public UserService(
            BarberMeDbContext context,
            IMapper mapper,
            IJwtService jwtService)
        {
            _context = context;
            _mapper = mapper;
            _jwtService = jwtService;
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

        public async Task<LoginResponse> Login(LoginRequest request)
        {
            var user = await _context.Users
                .Include(x => x.Role)
                .Include(x => x.BarberLevel)
                .FirstOrDefaultAsync(x => x.Username == request.Username);

            if (user == null)
                throw new Exception("Invalid username or password.");

            if (!user.IsActive)
                throw new Exception("User account is inactive.");

            if (user.IsLocked &&
                user.LockedUntil.HasValue &&
                user.LockedUntil > DateTime.UtcNow)
            {
                throw new Exception("User account is locked.");
            }

            var passwordValid = BCrypt.Net.BCrypt.Verify(
                request.Password,
                user.PasswordHash);

            if (!passwordValid)
            {
                user.FailedLoginAttempts++;

                if (user.FailedLoginAttempts >= 5)
                {
                    user.IsLocked = true;
                    user.LockedUntil = DateTime.UtcNow.AddMinutes(15);
                }

                await _context.SaveChangesAsync();

                throw new Exception("Invalid username or password.");
            }

            user.FailedLoginAttempts = 0;
            user.IsLocked = false;
            user.LockedUntil = null;

            await _context.SaveChangesAsync();

            var token = _jwtService.GenerateToken(user);

            return new LoginResponse
            {
                Token = token,
                User = _mapper.Map<UserResponse>(user)
            };
        }

        public async Task<UserResponse> Register(RegisterRequest request)
        {
            var usernameExists = await _context.Users
                .AnyAsync(x => x.Username == request.Username);

            if (usernameExists)
                throw new Exception("Username already exists.");

            var emailExists = await _context.Users
                .AnyAsync(x => x.Email == request.Email);

            if (emailExists)
                throw new Exception("Email already exists.");

            var clientRole = await _context.Roles
                .FirstOrDefaultAsync(x => x.Name == "Client");

            if (clientRole == null)
                throw new Exception("Client role does not exist.");

            var entity = new User
            {
                FirstName = request.FirstName,
                LastName = request.LastName,
                Username = request.Username,
                Email = request.Email,
                PhoneNumber = request.PhoneNumber,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
                RoleId = clientRole.RoleId,
                IsActive = true
            };

            _context.Users.Add(entity);
            await _context.SaveChangesAsync();

            var user = await _context.Users
                .Include(x => x.Role)
                .Include(x => x.BarberLevel)
                .FirstAsync(x => x.UserId == entity.UserId);

            return _mapper.Map<UserResponse>(user);
        }

        public async Task ForgotPassword(ForgotPasswordRequest request)
        {
            if (request.NewPassword != request.ConfirmPassword)
                throw new Exception("Passwords do not match.");

            var user = await _context.Users
                .FirstOrDefaultAsync(x => x.Email == request.Email);

            if (user == null)
                throw new Exception("User not found.");

            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);

            await _context.SaveChangesAsync();
        }

        public async Task ChangePassword(int userId, ChangePasswordRequest request)
        {
            if (request.NewPassword != request.ConfirmPassword)
                throw new Exception("Passwords do not match.");

            var user = await _context.Users
                .FirstOrDefaultAsync(x => x.UserId == userId);

            if (user == null)
                throw new Exception("User does not exist.");

            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
            user.RequirePasswordChange = false;

            await _context.SaveChangesAsync();
        }

        public async Task<string> UploadProfileImage(int userId, UploadProfileImageRequest request)
        {
            var user = await _context.Users.FindAsync(userId);

            if (user == null)
                throw new Exception("User not found.");

            var folder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "images", "profiles");
            Directory.CreateDirectory(folder);

            var extension = Path.GetExtension(request.File.FileName);
            var fileName = $"{Guid.NewGuid()}{extension}";
            var path = Path.Combine(folder, fileName);

            using var stream = new FileStream(path, FileMode.Create);
            await request.File.CopyToAsync(stream);

            user.ProfileImagePath = $"images/profiles/{fileName}";

            await _context.SaveChangesAsync();

            return user.ProfileImagePath;
        }
    }
}
