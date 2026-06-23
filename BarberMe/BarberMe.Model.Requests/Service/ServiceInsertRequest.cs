namespace BarberMe.Model.Requests.Service
{
    public class ServiceInsertRequest
    {
        public string Name { get; set; } = null!;

        public string? Description { get; set; }

        public decimal DefaultPrice { get; set; }

        public int DefaultDurationMinutes { get; set; }
    }
}
