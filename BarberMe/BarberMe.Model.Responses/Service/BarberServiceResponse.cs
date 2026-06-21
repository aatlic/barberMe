namespace BarberMe.Model.Responses.Service
{
    public class BarberServiceResponse : BaseResponse
    {
        public int BarberId { get; set; }
        public string BarberFullName { get; set; } = null!;

        public int ServiceId { get; set; }
        public string ServiceName { get; set; } = null!;

        public decimal Price { get; set; }
        public int DurationMinutes { get; set; }
    }
}
