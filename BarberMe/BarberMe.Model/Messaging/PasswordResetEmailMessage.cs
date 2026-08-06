namespace BarberMe.Model.Messaging
{
    public class PasswordResetEmailMessage
    {
        public string RecipientEmail { get; set; } = string.Empty;

        public string FirstName { get; set; } = string.Empty;

        public string TemporaryPassword { get; set; } = string.Empty;

        public DateTime ExpiresAt { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}