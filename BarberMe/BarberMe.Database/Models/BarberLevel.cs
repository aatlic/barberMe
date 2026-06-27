namespace BarberMe.Database.Models
{
    public class BarberLevel
    {
        public int BarberLevelId { get; set; }
        public string Name { get; set; } = string.Empty;
        public bool IsActive { get; set; } = true;

        public ICollection<User> Users { get; set; } = new List<User>();
    }
}
