using AutoMapper;
using BarberMe.Database.Context;
using BarberMe.Database.Models;
using BarberMe.Model.Constants;
using BarberMe.Model.Exceptions;
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
        private readonly ICurrentUserService _currentUserService;
        public UserService(
            BarberMeDbContext context,
            IMapper mapper,
            IJwtService jwtService,
            ICurrentUserService currentUserService)
        {
            _context = context;
            _mapper = mapper;
            _jwtService = jwtService;
            _currentUserService = currentUserService;
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

            if (page < 1)
                page = 1;

            if (pageSize < 1)
                pageSize = 10;

            if (pageSize > 100)
                pageSize = 100;

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

            if (entity == null)
                throw new NotFoundException("User does not exist.");

            return _mapper.Map<UserResponse>(entity);
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
                throw new NotFoundException("User does not exist.");

            _mapper.Map(request, entity);

            await _context.SaveChangesAsync();

            return _mapper.Map<UserResponse>(entity);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var entity = await _context.Users.FindAsync(id);

            if (entity == null)
                throw new NotFoundException("User does not exist.");

            if (!entity.IsActive)
                throw new BusinessException("User is already inactive.");

            entity.IsActive = false;

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
                throw new BusinessException("Invalid username or password.");

            if (!user.IsActive)
                throw new BusinessException("User account is inactive.");

            if (user.IsLocked &&
                user.LockedUntil.HasValue &&
                user.LockedUntil > DateTime.UtcNow)
            {
                throw new BusinessException("User account is locked.");
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

                throw new BusinessException("Invalid username or password.");
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
                throw new BusinessException("Username already exists.");

            var emailExists = await _context.Users
                .AnyAsync(x => x.Email == request.Email);

            if (emailExists)
                throw new BusinessException("Email already exists.");

            var clientRole = await _context.Roles
                .FirstOrDefaultAsync(x => x.Name == Roles.Client);

            if (clientRole == null)
                throw new NotFoundException("Client role does not exist.");

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
                throw new BusinessException("Passwords do not match.");

            var user = await _context.Users
                .FirstOrDefaultAsync(x => x.Email == request.Email);

            if (user == null)
                throw new NotFoundException("User not found.");

            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);

            await _context.SaveChangesAsync();
        }

        public async Task ChangePassword(ChangePasswordRequest request)
        {
            if (request.NewPassword != request.ConfirmPassword)
                throw new BusinessException("Passwords do not match.");

            var userId = _currentUserService.UserId;

            var user = await _context.Users
                .FirstOrDefaultAsync(x => x.UserId == userId);

            if (user == null)
                throw new NotFoundException("User does not exist.");

            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
            user.RequirePasswordChange = false;

            await _context.SaveChangesAsync();
        }

        public async Task<string> UploadProfileImage(UploadProfileImageRequest request)
        {
            var userId = _currentUserService.UserId;

            var user = await _context.Users.FindAsync(userId);

            if (user == null)
                throw new NotFoundException("User not found.");

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
