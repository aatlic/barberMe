namespace BarberMe.Model.Responses.Report
{
    public class BarberPerformanceReportResponse
    {
        public DateTime DateFrom { get; set; }

        public DateTime DateTo { get; set; }

        public int TotalCompletedAppointments { get; set; }

        public int TotalUniqueClients { get; set; }

        public decimal TotalRevenue { get; set; }

        public List<BarberPerformanceItemResponse> Barbers { get; set; } = new();

        public DateTime GeneratedAt { get; set; }
    }
}