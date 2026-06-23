namespace BarberMe.Model.Requests.BarberService
{
    public class BarberServiceInsertRequest
    {
        public int BarberId { get; set; }

        public int ServiceId { get; set; }

        public decimal Price { get; set; }

        public int DurationMinutes { get; set; }
    }
}
