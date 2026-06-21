namespace BarberMe.Model.Responses.Support
{
    public class SupportRequestResponse : BaseResponse
    {
        public string Subject { get; set; } = null!;

        public string Message { get; set; } = null!;

        public bool IsResolved { get; set; }

        public DateTime CreatedAt { get; set; }
    }
}
