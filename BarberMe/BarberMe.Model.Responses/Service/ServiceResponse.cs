namespace BarberMe.Model.Responses.Service
{
    public class ServiceResponse : BaseResponse
    {
        public string Name { get; set; } = null!;

        public string? Description { get; set; }

        public decimal DefaultPrice { get; set; }

        public int DefaultDurationMinutes { get; set; }

        public string? ImageUrl { get; set; }
    }
}
