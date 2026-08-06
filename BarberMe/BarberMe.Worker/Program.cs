using BarberMe.Database.Context;
using BarberMe.Model.Messaging;
using BarberMe.Worker;
using BarberMe.Worker.Configuration;
using BarberMe.Worker.Services;
using Microsoft.EntityFrameworkCore;

var builder = Host.CreateApplicationBuilder(args);

builder.Services.Configure<RabbitMQSettings>(
    builder.Configuration.GetSection("RabbitMQ"));

builder.Services.Configure<InternalApiSettings>(
    builder.Configuration.GetSection("InternalApi"));

builder.Services.Configure<SmtpSettings>(
    builder.Configuration.GetSection("Smtp"));

var connectionString =
    builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException(
        "Connection string 'DefaultConnection' is not configured.");

builder.Services.AddDbContext<BarberMeDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddScoped<INotificationProcessor,NotificationProcessor>();

builder.Services.AddScoped<IEmailSender, EmailSender>();
builder.Services.AddScoped<INewsletterProcessor, NewsletterProcessor>();

builder.Services.AddHttpClient<
    IInternalNotificationClient,
    InternalNotificationClient>((serviceProvider, client) =>
    {
        var configuration =
            serviceProvider.GetRequiredService<IConfiguration>();

        var baseUrl = configuration["InternalApi:BaseUrl"];

        if (string.IsNullOrWhiteSpace(baseUrl))
        {
            throw new InvalidOperationException(
                "InternalApi:BaseUrl is not configured.");
        }

        client.BaseAddress = new Uri(
            baseUrl.TrimEnd('/') + "/");
    });

builder.Services.AddHostedService<Worker>();
builder.Services.AddHostedService<AppointmentReminderWorker>();
builder.Services.AddHostedService<NewsletterWorker>();
builder.Services.AddHostedService<PasswordResetEmailWorker>();
builder.Services.AddHostedService<SupportRequestEmailWorker>();

var host = builder.Build();

host.Run();