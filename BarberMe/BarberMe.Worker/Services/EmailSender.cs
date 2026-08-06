using System.Net;
using System.Net.Mail;
using BarberMe.Worker.Configuration;
using Microsoft.Extensions.Options;

namespace BarberMe.Worker.Services
{
    public class EmailSender : IEmailSender
    {
        private readonly SmtpSettings _settings;
        private readonly ILogger<EmailSender> _logger;

        public EmailSender(
            IOptions<SmtpSettings> settings,
            ILogger<EmailSender> logger)
        {
            _settings = settings.Value;
            _logger = logger;
        }

        public async Task SendAsync(
            string recipientEmail,
            string subject,
            string body,
            CancellationToken cancellationToken = default)
        {
            using var message = new MailMessage
            {
                From = new MailAddress(
                    _settings.Username,
                    _settings.FromName),

                Subject = subject,
                Body = body,
                IsBodyHtml = false
            };

            message.To.Add(recipientEmail);

            using var smtpClient = new SmtpClient(
                _settings.Host,
                _settings.Port)
            {
                EnableSsl = _settings.EnableSsl,
                Credentials = new NetworkCredential(
                    _settings.Username,
                    _settings.Password)
            };

            cancellationToken.ThrowIfCancellationRequested();

            await smtpClient.SendMailAsync(
                message,
                cancellationToken);

            _logger.LogInformation(
                "Email sent to {RecipientEmail}.",
                recipientEmail);
        }
    }
}