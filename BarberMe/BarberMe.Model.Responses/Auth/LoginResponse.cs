using BarberMe.Model.Responses.User;

namespace BarberMe.Model.Responses.Auth
{
    public class LoginResponse
    {
        public string Token { get; set; } = null!;
        public UserResponse User { get; set; } = null!;
    }
}
