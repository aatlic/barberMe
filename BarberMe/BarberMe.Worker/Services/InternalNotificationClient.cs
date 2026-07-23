using System.Net.Http.Json;
using BarberMe.Model.Messaging;
using BarberMe.Worker.Configuration;
using Microsoft.Extensions.Options;

namespace BarberMe.Worker.Services
{
    public class InternalNotificationClient : IInternalNotificationClient
    {
        private readonly HttpClient _httpClient;
        private readonly InternalApiSettings _settings;
        private readonly ILogger<InternalNotificationClient> _logger;

        public InternalNotificationClient(
            HttpClient httpClient,
            IOptions<InternalApiSettings> options,
            ILogger<InternalNotificationClient> logger)
        {
            _httpClient = httpClient;
            _settings = options.Value;
            _logger = logger;
        }

        public async Task SendAsync(
            NotificationMessage message,
            CancellationToken cancellationToken = default)
        {
            using var request = new HttpRequestMessage(
                HttpMethod.Post,
                "api/internal/notifications/send");

            request.Headers.Add(
                "X-Internal-Api-Key",
                _settings.Key);

            request.Content = JsonContent.Create(message);

            using var response = await _httpClient.SendAsync(
                request,
                cancellationToken);

            if (!response.IsSuccessStatusCode)
            {
                var responseBody = await response.Content
                    .ReadAsStringAsync(cancellationToken);

                throw new HttpRequestException(
                    $"Internal notification API returned {(int)response.StatusCode}. Response: {responseBody}");
            }

            _logger.LogInformation(
                "Internal SignalR notification request sent for user {UserId}.",
                message.UserId);
        }
    }
}