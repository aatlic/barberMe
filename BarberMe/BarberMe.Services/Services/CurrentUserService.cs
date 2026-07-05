using BarberMe.Services.Interfaces;
using Microsoft.AspNetCore.Http;
using System.Security.Claims;

namespace BarberMe.Services.Services
{
    public class CurrentUserService : ICurrentUserService
    {
        private readonly IHttpContextAccessor _httpContextAccessor;

        public CurrentUserService(IHttpContextAccessor httpContextAccessor)
        {
            _httpContextAccessor = httpContextAccessor;
        }

        public bool IsAuthenticated =>
            _httpContextAccessor.HttpContext?.User?.Identity?.IsAuthenticated ?? false;

        public int UserId
        {
            get
            {
                var userId = _httpContextAccessor.HttpContext?.User
                    ?.FindFirst(ClaimTypes.NameIdentifier)?.Value;

                return int.TryParse(userId, out var id) ? id : 0;
            }
        }

        public string Role =>
            _httpContextAccessor.HttpContext?.User
                ?.FindFirst(ClaimTypes.Role)?.Value ?? string.Empty;
    }
}