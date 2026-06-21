namespace BarberMe.Model.Responses.Appointment
{
    public class ReviewResponse : BaseResponse
    {
        public int AppointmentId { get; set; }

        public int ClientId { get; set; }
        public string ClientFullName { get; set; } = null!;

        public int BarberId { get; set; }
        public string BarberFullName { get; set; } = null!;

        public int Rating { get; set; }
        public string? Comment { get; set; }

        public DateTime CreatedAt { get; set; }
    }
}
