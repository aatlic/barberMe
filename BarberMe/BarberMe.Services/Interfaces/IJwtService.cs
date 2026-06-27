using BarberMe.Database.Models;

namespace BarberMe.Services.Interfaces
{
    public interface IJwtService
    {
        string GenerateToken(User user);
    }
}