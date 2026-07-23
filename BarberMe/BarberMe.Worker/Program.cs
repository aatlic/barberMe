using BarberMe.Database.Context;
using BarberMe.Model.Messaging;
using BarberMe.Worker;
using BarberMe.Worker.Services;
using Microsoft.EntityFrameworkCore;

var builder = Host.CreateApplicationBuilder(args);

builder.Services.Configure<RabbitMQSettings>(
    builder.Configuration.GetSection("RabbitMQ"));

var connectionString =
    builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException(
        "Connection string 'DefaultConnection' is not configured.");

builder.Services.AddDbContext<BarberMeDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddScoped<
    INotificationProcessor,
    NotificationProcessor>();

builder.Services.AddHostedService<Worker>();

var host = builder.Build();

host.Run();