namespace BarberMe.Model.Responses.User
{
    public class UserResponse : BaseResponse
    {
        public string FirstName { get; set; } = null!;
        public string LastName { get; set; } = null!;

        public string Username { get; set; } = null!;

        public string Email { get; set; } = null!;

        public string PhoneNumber { get; set; } = null!;

        public string? ProfileImagePath { get; set; }

        public RoleResponse Role { get; set; } = null!;

        public BarberLevelResponse? BarberLevel { get; set; }
    }
}
