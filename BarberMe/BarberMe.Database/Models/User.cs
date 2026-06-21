namespace BarberMe.Database.Models
{
    public class User
    {
        public int UserId { get; set; }

        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string Username { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string PhoneNumber { get; set; } = string.Empty;

        public string PasswordHash { get; set; } = string.Empty;
        public string? ProfileImage { get; set; }

        public int RoleId { get; set; }
        public Role Role { get; set; } = null!;

        public int? BarberLevelId { get; set; }
        public BarberLevel? BarberLevel { get; set; }

        public int FailedLoginAttempts { get; set; }
        public bool IsLocked { get; set; }
        public DateTime? LockedUntil { get; set; }

        public bool IsActive { get; set; } = true;
        public bool RequirePasswordChange { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public ICollection<BarberService> BarberServices { get; set; } = new List<BarberService>();
        public ICollection<WorkingHours> WorkingHours { get; set; } = new List<WorkingHours>();
    }
}
