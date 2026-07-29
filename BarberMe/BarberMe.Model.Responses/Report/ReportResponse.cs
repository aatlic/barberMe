namespace BarberMe.Model.Responses.Report
{
    public class ReportResponse
    {
        public DateTime DateFrom { get; set; }
        public DateTime DateTo { get; set; }

        public int? BarberId { get; set; }
        public string BarberName { get; set; } = "All barbers";

        public int TotalAppointments { get; set; }
        public int CompletedAppointments { get; set; }
        public int CancelledAppointments { get; set; }

        public int UniqueClients { get; set; }

        public decimal TotalRevenue { get; set; }

        public List<ReportServiceItemResponse> Services { get; set; } = new();

        public List<ReportAppointmentItemResponse> Appointments { get; set; } = new();

        public DateTime GeneratedAt { get; set; }
    }
}