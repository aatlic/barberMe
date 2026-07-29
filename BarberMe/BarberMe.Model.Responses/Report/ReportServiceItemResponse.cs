namespace BarberMe.Model.Responses.Report
{
    public class ReportServiceItemResponse
    {
        public int ServiceId { get; set; }
        public string ServiceName { get; set; } = string.Empty;

        public int AppointmentCount { get; set; }

        public decimal UnitPrice { get; set; }
        public decimal TotalRevenue { get; set; }
    }
}