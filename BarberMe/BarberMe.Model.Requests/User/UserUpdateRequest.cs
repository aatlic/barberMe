namespace BarberMe.Model.Requests.User
{
    public class UserUpdateRequest
    {
        public string FirstName { get; set; } = null!;

        public string LastName { get; set; } = null!;

        public string Email { get; set; } = null!;

        public string PhoneNumber { get; set; } = null!;

        public int? BarberLevelId { get; set; }

        public bool IsActive { get; set; }
    }
}
