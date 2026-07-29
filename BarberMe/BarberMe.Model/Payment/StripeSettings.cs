namespace BarberMe.Model.Payment
{
    public class StripeSettings
    {
        public string SecretKey { get; set; } = null!;
        public string PublishableKey { get; set; } = null!;
        public string WebhookSecret { get; set; } = null!;
        public string Currency { get; set; } = "bam";
    }
}