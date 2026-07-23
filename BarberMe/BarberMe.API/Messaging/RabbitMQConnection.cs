using BarberMe.Model.Messaging;
using Microsoft.Extensions.Options;
using RabbitMQ.Client;

namespace BarberMe.API.Messaging
{
    public sealed class RabbitMQConnection : IAsyncDisposable
    {
        private readonly RabbitMQSettings _settings;
        private readonly ILogger<RabbitMQConnection> _logger;
        private readonly SemaphoreSlim _connectionLock = new(1, 1);

        private IConnection? _connection;

        public RabbitMQConnection(
            IOptions<RabbitMQSettings> options,
            ILogger<RabbitMQConnection> logger)
        {
            _settings = options.Value;
            _logger = logger;
        }

        public async Task<IConnection> GetConnectionAsync(
            CancellationToken cancellationToken = default)
        {
            if (_connection is { IsOpen: true })
            {
                return _connection;
            }

            await _connectionLock.WaitAsync(cancellationToken);

            try
            {
                if (_connection is { IsOpen: true })
                {
                    return _connection;
                }

                if (_connection is not null)
                {
                    await _connection.DisposeAsync();
                    _connection = null;
                }

                var factory = new ConnectionFactory
                {
                    HostName = _settings.HostName,
                    Port = _settings.Port,
                    UserName = _settings.UserName,
                    Password = _settings.Password,

                    AutomaticRecoveryEnabled = true,
                    NetworkRecoveryInterval = TimeSpan.FromSeconds(5)
                };

                _connection = await factory.CreateConnectionAsync(
                    clientProvidedName: "BarberMe.API",
                    cancellationToken: cancellationToken);

                _logger.LogInformation(
                    "RabbitMQ connection established to {HostName}:{Port}.",
                    _settings.HostName,
                    _settings.Port);

                return _connection;
            }
            finally
            {
                _connectionLock.Release();
            }
        }

        public async ValueTask DisposeAsync()
        {
            if (_connection is not null)
            {
                await _connection.DisposeAsync();
            }

            _connectionLock.Dispose();
        }
    }
}