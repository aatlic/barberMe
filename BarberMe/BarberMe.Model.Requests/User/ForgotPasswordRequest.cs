namespace BarberMe.Model.Requests.User
{
    public class ForgotPasswordRequest
    {
        public string Email { get; set; } = null!;

        public string NewPassword { get; set; } = null!;

        public string ConfirmPassword { get; set; } = null!;
    }
}
