namespace BarberMe.Database.Models
{
    public class News
    {
        public int NewsId { get; set; }

        public string Title { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
        public string? Image { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
