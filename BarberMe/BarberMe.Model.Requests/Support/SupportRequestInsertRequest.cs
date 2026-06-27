namespace BarberMe.Model.Requests.Support
{
    public class SupportRequestInsertRequest
    {
        public string FullName { get; set; } = null!;

        public string Email { get; set; } = null!;

        public string Subject { get; set; } = null!;

        public string Message { get; set; } = null!;
    }
}
