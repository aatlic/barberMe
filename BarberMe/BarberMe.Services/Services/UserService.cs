using AutoMapper;
using BarberMe.Database.Context;
using BarberMe.Database.Models;
using BarberMe.Model.Constants;
using BarberMe.Model.Enum;
using BarberMe.Model.Exceptions;
using BarberMe.Model.Requests.Auth;
using BarberMe.Model.Requests.User;
using BarberMe.Model.Responses;
using BarberMe.Model.Responses.Auth;
using BarberMe.Model.Responses.User;
using BarberMe.Model.SearchObjects;
using BarberMe.Services.Helpers;
using BarberMe.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using System.Security.Cryptography;

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

        private int GetCurrentUserId()
        {
            var userId = _currentUserService.UserId;

            if (!_currentUserService.IsAuthenticated || userId <= 0)
                throw new UnauthorizedException("User is not authenticated.");

            return userId;
        }

        private void ValidateUserAccess(int targetUserId)
        {
            var currentUserId = GetCurrentUserId();

            var isAdmin = string.Equals(
                _currentUserService.Role,
                Roles.Admin,
                StringComparison.OrdinalIgnoreCase);

            if (!isAdmin && currentUserId != targetUserId)
            {
                throw new UnauthorizedException(
                    "You are not allowed to access another user's data.");
            }
        }

        private void ValidateAdminAccess()
        {
            GetCurrentUserId();

            var isAdmin = string.Equals(
                _currentUserService.Role,
                Roles.Admin,
                StringComparison.OrdinalIgnoreCase);

            if (!isAdmin)
            {
                throw new UnauthorizedException(
                    "Only an administrator can perform this action.");
            }
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
            ValidateUserAccess(id);

            var entity = await _context.Users
                .AsNoTracking()
                .Include(x => x.Role)
                .Include(x => x.BarberLevel)
                .FirstOrDefaultAsync(x => x.UserId == id);

            if (entity == null)
                throw new NotFoundException("User does not exist.");

            return _mapper.Map<UserResponse>(entity);
        }

        public async Task<UserResponse> GetCurrentAsync()
        {
            var userId = GetCurrentUserId();

            var entity = await _context.Users
                .AsNoTracking()
                .Include(x => x.Role)
                .Include(x => x.BarberLevel)
                .FirstOrDefaultAsync(x => x.UserId == userId);

            if (entity == null)
                throw new NotFoundException("User does not exist.");

            return _mapper.Map<UserResponse>(entity);
        }

        public async Task<UserResponse> InsertAsync(UserInsertRequest request)
        {
            var usernameExists = await _context.Users
                .AnyAsync(x => x.Username == request.Username);

            if (usernameExists)
                throw new BusinessException("Username already exists.");

            var emailExists = await _context.Users
                .AnyAsync(x => x.Email == request.Email);

            if (emailExists)
                throw new BusinessException("Email already exists.");

            var role = await _context.Roles
                .FirstOrDefaultAsync(x => x.RoleId == request.RoleId);

            if (role == null)
                throw new NotFoundException("Role does not exist.");

            if (role.Name == Roles.Barber)
            {
                if (!request.BarberLevelId.HasValue)
                    throw new BusinessException("Barber level is required for barber users.");

                var barberLevelExists = await _context.BarberLevels
                    .AnyAsync(x => x.BarberLevelId == request.BarberLevelId.Value);

                if (!barberLevelExists)
                    throw new NotFoundException("Barber level does not exist.");
            }
            else
            {
                request.BarberLevelId = null;
            }

            var entity = _mapper.Map<User>(request);

            entity.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);
            entity.IsActive = true;
            entity.FailedLoginAttempts = 0;
            entity.IsLocked = false;
            entity.LockedUntil = null;

            entity.RequirePasswordChange = request.RequirePasswordChange;

            entity.CreatedAt = DateTime.UtcNow;

            _context.Users.Add(entity);
            await _context.SaveChangesAsync();

            var user = await _context.Users
                .Include(x => x.Role)
                .Include(x => x.BarberLevel)
                .FirstAsync(x => x.UserId == entity.UserId);

            return _mapper.Map<UserResponse>(user);
        }

        public async Task<UserResponse?> UpdateAsync(int id, UserUpdateRequest request)
        {
            ValidateUserAccess(id);

            var entity = await _context.Users
                .Include(x => x.Role)
                .FirstOrDefaultAsync(x => x.UserId == id);

            if (entity == null)
                throw new NotFoundException("User does not exist.");

            var emailExists = await _context.Users
                .AnyAsync(x => x.UserId != id && x.Email == request.Email);

            if (emailExists)
                throw new BusinessException("Email already exists.");

            if (entity.Role.Name == Roles.Barber)
            {
                if (!request.BarberLevelId.HasValue)
                    throw new BusinessException("Barber level is required for barber users.");

                var barberLevelExists = await _context.BarberLevels
                    .AnyAsync(x => x.BarberLevelId == request.BarberLevelId.Value);

                if (!barberLevelExists)
                    throw new NotFoundException("Barber level does not exist.");
            }
            else
            {
                request.BarberLevelId = null;
            }

            _mapper.Map(request, entity);

            await _context.SaveChangesAsync();

            var user = await _context.Users
                .Include(x => x.Role)
                .Include(x => x.BarberLevel)
                .FirstAsync(x => x.UserId == id);

            return _mapper.Map<UserResponse>(user);
        }

        public async Task<UserResponse> UpdateCurrentAsync(UserProfileUpdateRequest request)
        {
            var userId = GetCurrentUserId();

            var user = await _context.Users
                .Include(x => x.Role)
                .Include(x => x.BarberLevel)
                .FirstOrDefaultAsync(x => x.UserId == userId);

            if (user == null)
                throw new NotFoundException("User does not exist.");

            var normalizedEmail = request.Email.Trim().ToLower();

            var emailExists = await _context.Users.AnyAsync(x =>
                x.UserId != userId &&
                x.Email.ToLower() == normalizedEmail);

            if (emailExists)
                throw new BusinessException("Email already exists.");

            user.FirstName = request.FirstName.Trim();
            user.LastName = request.LastName.Trim();
            user.Email = request.Email.Trim();
            user.PhoneNumber = request.PhoneNumber.Trim();

            await _context.SaveChangesAsync();

            return _mapper.Map<UserResponse>(user);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            ValidateAdminAccess();

            var currentUserId = GetCurrentUserId();

            if (id == currentUserId)
            {
                throw new BusinessException("Administrator cannot delete their own account.");
            }

            var user = await _context.Users
                .FirstOrDefaultAsync(x => x.UserId == id);

            if (user == null)
                throw new NotFoundException("User does not exist.");

            var hasAppointments =
                await _context.Appointments.AnyAsync(x =>
                    x.ClientId == id ||
                    x.BarberId == id ||
                    x.ConfirmedById == id ||
                    x.CancelledById == id ||
                    x.CompletedById == id);

            if (hasAppointments)
            {
                throw new BusinessException("User cannot be permanently deleted because appointment history exists. Deactivate the user instead.");
            }

            var hasReviews =
                await _context.Reviews.AnyAsync(x =>
                    x.ClientId == id ||
                    x.BarberId == id);

            if (hasReviews)
            {
                throw new BusinessException("User cannot be permanently deleted because review history exists. Deactivate the user instead.");
            }

            var hasNotifications =
                await _context.Notifications.AnyAsync(x =>
                    x.UserId == id);

            if (hasNotifications)
            {
                throw new BusinessException("User cannot be permanently deleted because notifications exist. Deactivate the user instead.");
            }

            var hasSupportRequests =
                await _context.SupportRequests.AnyAsync(x =>
                    x.UserId == id);

            if (hasSupportRequests)
            {
                throw new BusinessException("User cannot be permanently deleted because support request history exists. Deactivate the user instead.");
            }

            await using var transaction = await _context.Database.BeginTransactionAsync();

            try
            {
                var workingHours =
                    await _context.WorkingHours
                        .Where(x => x.BarberId == id)
                        .ToListAsync();

                if (workingHours.Count > 0)
                {
                    _context.WorkingHours.RemoveRange(
                        workingHours);
                }

                var barberServices =
                    await _context.BarberServices
                        .Where(x => x.BarberId == id)
                        .ToListAsync();

                if (barberServices.Count > 0)
                {
                    _context.BarberServices.RemoveRange(
                        barberServices);
                }

                _context.Users.Remove(user);

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                ImageStorageHelper.DeleteImageIfExists(user.ProfileImagePath);

                return true;
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }
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
                user.LockedUntil <= DateTime.UtcNow)
            {
                user.IsLocked = false;
                user.LockedUntil = null;
                user.FailedLoginAttempts = 0;

                await _context.SaveChangesAsync();
            }

            if (user.IsLocked)
            {
                throw new BusinessException(
                    "User account is locked. Please contact support or try again later.");
            }

            if (user.RequirePasswordChange &&
                user.TemporaryPasswordExpiresAt.HasValue &&
                user.TemporaryPasswordExpiresAt <= DateTime.UtcNow)
            {
                throw new BusinessException(
                    "The temporary password has expired. Request a new password.");
            }

            var passwordValid = true;
            //var passwordValid = BCrypt.Net.BCrypt.Verify(
            //    request.Password,
            //    user.PasswordHash);

            if (!passwordValid)
            {
                user.FailedLoginAttempts++;

                if (user.FailedLoginAttempts >= 3)
                {
                    user.IsLocked = true;
                    user.LockedUntil = DateTime.UtcNow.AddMinutes(15);

                    await _context.SaveChangesAsync();

                    throw new BusinessException(
                        "User account has been locked after three unsuccessful login attempts.");
                }

                await _context.SaveChangesAsync();

                var remainingAttempts = 3 - user.FailedLoginAttempts;

                throw new BusinessException(
                    $"Invalid username or password. Remaining attempts: {remainingAttempts}.");
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

        public async Task<string?> ForgotPassword(ForgotPasswordRequest request)
        {
            var normalizedEmail = request.Email.Trim().ToLower();

            var user = await _context.Users
                .FirstOrDefaultAsync(x =>
                    x.Email.ToLower() == normalizedEmail);

            if (user == null || !user.IsActive)
                return null;

            var temporaryPassword = GenerateTemporaryPassword();

            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(
                temporaryPassword);

            user.RequirePasswordChange = true;
            user.TemporaryPasswordExpiresAt =
                DateTime.UtcNow.AddHours(24);

            user.FailedLoginAttempts = 0;
            user.IsLocked = false;
            user.LockedUntil = null;

            await _context.SaveChangesAsync();

            return temporaryPassword;
        }

        private static string GenerateTemporaryPassword()
        {
            const string upper = "ABCDEFGHJKLMNPQRSTUVWXYZ";
            const string lower = "abcdefghijkmnopqrstuvwxyz";
            const string digits = "23456789";
            const string special = "!@$?";

            var allCharacters = upper + lower + digits + special;

            var characters = new List<char>
            {
                upper[RandomNumberGenerator.GetInt32(upper.Length)],
                lower[RandomNumberGenerator.GetInt32(lower.Length)],
                digits[RandomNumberGenerator.GetInt32(digits.Length)],
                special[RandomNumberGenerator.GetInt32(special.Length)]
            };

            while (characters.Count < 12)
            {
                characters.Add(
                    allCharacters[
                        RandomNumberGenerator.GetInt32(allCharacters.Length)]);
            }

            for (var i = characters.Count - 1; i > 0; i--)
            {
                var j = RandomNumberGenerator.GetInt32(i + 1);

                (characters[i], characters[j]) =
                    (characters[j], characters[i]);
            }

            return new string(characters.ToArray());
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

            var oldPasswordValid = BCrypt.Net.BCrypt.Verify(
                request.OldPassword,
                user.PasswordHash);

            if (!oldPasswordValid)
                throw new BusinessException("Current password is incorrect.");

            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
            user.RequirePasswordChange = false;
            user.TemporaryPasswordExpiresAt = null;

            await _context.SaveChangesAsync();
        }

        public async Task<string> UploadProfileImage(UploadProfileImageRequest request)
        {
            var userId = _currentUserService.UserId;

            var user = await _context.Users.FindAsync(userId);

            if (user == null)
                throw new NotFoundException("User not found.");

            ImageValidator.Validate(request.File);

            ImageStorageHelper.DeleteImageIfExists(user.ProfileImagePath);

            user.ProfileImagePath = await ImageStorageHelper.SaveImageAsync(
                request.File,
                "profiles");

            await _context.SaveChangesAsync();

            return user.ProfileImagePath;
        }

        public async Task LockUserAsync(int id)
        {
            ValidateAdminAccess();

            var user = await _context.Users
                .FirstOrDefaultAsync(x => x.UserId == id);

            if (user == null)
                throw new NotFoundException("User does not exist.");

            if (user.UserId == _currentUserService.UserId)
            {
                throw new BusinessException(
                    "Administrator cannot lock their own account.");
            }

            if (user.IsLocked)
                throw new BusinessException("User account is already locked.");

            user.IsLocked = true;

            user.LockedUntil = null;
            user.FailedLoginAttempts = 3;

            await _context.SaveChangesAsync();
        }

        public async Task UnlockUserAsync(int id)
        {
            ValidateAdminAccess();

            var user = await _context.Users
                .FirstOrDefaultAsync(x => x.UserId == id);

            if (user == null)
                throw new NotFoundException("User does not exist.");

            if (!user.IsLocked && user.FailedLoginAttempts == 0)
                throw new BusinessException("User account is not locked.");

            user.IsLocked = false;
            user.LockedUntil = null;
            user.FailedLoginAttempts = 0;

            await _context.SaveChangesAsync();
        }

        public string GenerateInitialPassword()
        {
            ValidateAdminAccess();

            return GenerateTemporaryPassword();
        }

        public async Task<UserResponse> CopyEmployeeAsync(
            int sourceEmployeeId,
            CopyEmployeeRequest request)
        {
            ValidateAdminAccess();

            var sourceEmployee = await _context.Users
                .AsNoTracking()
                .Include(x => x.Role)
                .FirstOrDefaultAsync(x =>
                    x.UserId == sourceEmployeeId);

            if (sourceEmployee == null)
                throw new NotFoundException("Source employee does not exist.");

            if (sourceEmployee.Role.Name != Roles.Barber)
            {
                throw new BusinessException(
                    "Only barber employees can be copied.");
            }

            if (!sourceEmployee.IsActive)
            {
                throw new BusinessException(
                    "An inactive employee cannot be copied.");
            }

            var normalizedUsername =
                request.Username.Trim().ToLower();

            var normalizedEmail =
                request.Email.Trim().ToLower();

            var usernameExists = await _context.Users
                .AnyAsync(x =>
                    x.Username.ToLower() == normalizedUsername);

            if (usernameExists)
                throw new BusinessException("Username already exists.");

            var emailExists = await _context.Users
                .AnyAsync(x =>
                    x.Email.ToLower() == normalizedEmail);

            if (emailExists)
                throw new BusinessException("Email already exists.");

            await using var transaction =
                await _context.Database.BeginTransactionAsync();

            try
            {
                var newEmployee = new User
                {
                    FirstName = request.FirstName.Trim(),
                    LastName = request.LastName.Trim(),
                    Username = request.Username.Trim(),
                    Email = request.Email.Trim(),
                    PhoneNumber = request.PhoneNumber.Trim(),

                    PasswordHash = BCrypt.Net.BCrypt.HashPassword(
                        request.Password),

                    RoleId = sourceEmployee.RoleId,

                    BarberLevelId = sourceEmployee.BarberLevelId,

                    IsActive = true,
                    IsLocked = false,
                    LockedUntil = null,
                    FailedLoginAttempts = 0,

                    RequirePasswordChange =
                        request.RequirePasswordChange,

                    CreatedAt = DateTime.UtcNow
                };

                _context.Users.Add(newEmployee);

                await _context.SaveChangesAsync();

                if (request.CopyServices)
                {
                    var sourceServices = await _context.BarberServices
                        .AsNoTracking()
                        .Where(x =>
                            x.BarberId == sourceEmployeeId)
                        .ToListAsync();

                    var copiedServices = sourceServices.Select(x =>
                        new BarberService
                        {
                            BarberId = newEmployee.UserId,
                            ServiceId = x.ServiceId,
                            Price = x.Price,
                            DurationMinutes = x.DurationMinutes,
                            CreatedAt = DateTime.UtcNow
                        })
                        .ToList();

                    if (copiedServices.Count > 0)
                    {
                        _context.BarberServices.AddRange(
                            copiedServices);

                        await _context.SaveChangesAsync();
                    }
                }

                await transaction.CommitAsync();

                var createdEmployee = await _context.Users
                    .AsNoTracking()
                    .Include(x => x.Role)
                    .Include(x => x.BarberLevel)
                    .FirstAsync(x =>
                        x.UserId == newEmployee.UserId);

                return _mapper.Map<UserResponse>(
                    createdEmployee);
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }
        }

        public async Task DeactivateUserAsync(int id)
        {
            ValidateAdminAccess();

            var currentUserId = GetCurrentUserId();

            if (id == currentUserId)
            {
                throw new BusinessException(
                    "Administrator cannot deactivate their own account.");
            }

            var user = await _context.Users
                .FirstOrDefaultAsync(x => x.UserId == id);

            if (user == null)
                throw new NotFoundException("User does not exist.");

            if (!user.IsActive)
                throw new BusinessException("User is already inactive.");

            var cancelledStatusId =
                (int)AppointmentStatusType.Cancelled;

            var hasFutureAppointments =
                await _context.Appointments.AnyAsync(x =>
                    (x.ClientId == id || x.BarberId == id) &&
                    x.StartDateTime > DateTime.UtcNow &&
                    x.AppointmentStatusId != cancelledStatusId);

            if (hasFutureAppointments)
            {
                throw new BusinessException(
                    "User cannot be deactivated because they have future active appointments.");
            }

            user.IsActive = false;

            await _context.SaveChangesAsync();
        }

        public async Task ActivateUserAsync(int id)
        {
            ValidateAdminAccess();

            var user = await _context.Users
                .FirstOrDefaultAsync(x => x.UserId == id);

            if (user == null)
                throw new NotFoundException("User does not exist.");

            if (user.IsActive)
                throw new BusinessException("User is already active.");

            user.IsActive = true;

            await _context.SaveChangesAsync();
        }
    }
}
