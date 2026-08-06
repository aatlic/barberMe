namespace BarberMe.Model.Responses.Report
{
    public class ReportAppointmentItemResponse
    {
        public int AppointmentId { get; set; }

        public string ClientName { get; set; } = string.Empty;
        public string BarberName { get; set; } = string.Empty;
        public string ServiceName { get; set; } = string.Empty;

        public DateTime StartDateTime { get; set; }

        public string Status { get; set; } = string.Empty;

        public decimal BasePrice { get; set; }

        public decimal AppliedDiscountPercent { get; set; }

        public decimal AppliedPenaltyPercent { get; set; }

        public decimal FinalPrice { get; set; }

        public bool IsPaid { get; set; }
    }
}