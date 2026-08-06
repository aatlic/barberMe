namespace BarberMe.Worker.Helpers
{
    public static class RabbitMqRetryHelper
    {
        private const int MaxAttempts = 5;

        public static async Task ExecuteAsync(
            Func<Task> operation,
            ILogger logger,
            string operationName,
            CancellationToken cancellationToken)
        {
            ArgumentNullException.ThrowIfNull(operation);
            ArgumentNullException.ThrowIfNull(logger);

            for (var attempt = 1; attempt <= MaxAttempts; attempt++)
            {
                cancellationToken.ThrowIfCancellationRequested();

                try
                {
                    await operation();
                    return;
                }
                catch (OperationCanceledException)
                    when (cancellationToken.IsCancellationRequested)
                {
                    throw;
                }
                catch (Exception exception)
                    when (attempt < MaxAttempts)
                {
                    var delaySeconds =
                        (int)Math.Pow(2, attempt - 1);

                    _ = exception;

                    logger.LogWarning(
                        exception,
                        "{OperationName} failed on attempt {Attempt}/{MaxAttempts}. " +
                        "Retrying in {DelaySeconds} seconds.",
                        operationName,
                        attempt,
                        MaxAttempts,
                        delaySeconds);

                    await Task.Delay(
                        TimeSpan.FromSeconds(delaySeconds),
                        cancellationToken);
                }
            }

            throw new InvalidOperationException(
                $"{operationName} failed after {MaxAttempts} attempts.");
        }
    }
}