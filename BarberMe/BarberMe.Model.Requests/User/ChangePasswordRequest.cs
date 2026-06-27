namespace BarberMe.Model.Requests.User
{
    public class ChangePasswordRequest
    {
        public string NewPassword { get; set; } = null!;

        public string ConfirmPassword { get; set; } = null!;
    }
}
