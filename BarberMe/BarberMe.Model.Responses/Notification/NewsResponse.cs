namespace BarberMe.Model.Responses.Notification
{
    public class NewsResponse : BaseResponse
    {
        public string Title { get; set; } = null!;

        public string Content { get; set; } = null!;

        public string? Image { get; set; }

        public DateTime CreatedAt { get; set; }
    }
}
