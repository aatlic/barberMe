using BarberMe.Database.Context;
using BarberMe.Model.Messaging;
using Microsoft.EntityFrameworkCore;

namespace BarberMe.Worker.Services
{
    public class NewsletterProcessor : INewsletterProcessor
    {
        private readonly BarberMeDbContext _context;
        private readonly IEmailSender _emailSender;
        private readonly ILogger<NewsletterProcessor> _logger;

        public NewsletterProcessor(
            BarberMeDbContext context,
            IEmailSender emailSender,
            ILogger<NewsletterProcessor> logger)
        {
            _context = context;
            _emailSender = emailSender;
            _logger = logger;
        }

        public async Task ProcessAsync(
            NewsletterMessage message,
            CancellationToken cancellationToken = default)
        {
            var recipients = await _context.Users
                .AsNoTracking()
                .Where(x =>
                    x.IsActive &&
                    x.ReceiveNewsletter)
                .Select(x => new
                {
                    x.Email,
                    x.FirstName
                })
                .ToListAsync(cancellationToken);

            if (recipients.Count == 0)
            {
                _logger.LogInformation(
                    "No newsletter subscribers were found for event {EventType}.",
                    message.EventType);

                return;
            }

            foreach (var recipient in recipients)
            {
                try
                {
                    var personalizedBody =
                        $"Poštovani/Poštovana {recipient.FirstName},\n\n" +
                        message.Body +
                        "\n\nSrdačan pozdrav,\nBarber Me";

                    await _emailSender.SendAsync(
                        recipient.Email,
                        message.Subject,
                        personalizedBody,
                        cancellationToken);

                    _logger.LogInformation(
                        "Newsletter event {EventType} sent to {RecipientEmail}.",
                        message.EventType,
                        recipient.Email);
                }
                catch (Exception exception)
                {
                    _logger.LogError(
                        exception,
                        "Newsletter event {EventType} could not be sent to {RecipientEmail}.",
                        message.EventType,
                        recipient.Email);
                }
            }
        }
    }
}