namespace BarberMe.Model.Responses.Report
{
    public class BarberPerformanceItemResponse
    {
        public int BarberId { get; set; }

        public string BarberName { get; set; } = string.Empty;

        public int CompletedAppointments { get; set; }

        public int UniqueClients { get; set; }

        public decimal TotalRevenue { get; set; }

        public double AverageRating { get; set; }

        public string MostPopularService { get; set; } = "No data";
    }
}