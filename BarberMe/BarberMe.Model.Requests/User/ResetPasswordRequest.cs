namespace BarberMe.Model.Requests.User
{
    public class ResetPasswordRequest
    {
        public string Token { get; set; } = null!;

        public string Password { get; set; } = null!;

        public string ConfirmPassword { get; set; } = null!;
    }
}
