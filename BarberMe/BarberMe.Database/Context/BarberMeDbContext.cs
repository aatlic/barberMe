using BarberMe.Database.Models;
using Microsoft.EntityFrameworkCore;

namespace BarberMe.Database.Context
{
    public class BarberMeDbContext : DbContext
    {
        public BarberMeDbContext(DbContextOptions<BarberMeDbContext> options)
            : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        public DbSet<Role> Roles { get; set; }
        public DbSet<BarberLevel> BarberLevels { get; set; }
        public DbSet<Service> Services { get; set; }
        public DbSet<BarberService> BarberServices { get; set; }
        public DbSet<WorkingHours> WorkingHours { get; set; }
        public DbSet<Appointment> Appointments { get; set; }
        public DbSet<AppointmentStatus> AppointmentStatuses { get; set; }
        public DbSet<Review> Reviews { get; set; }
        public DbSet<Payment> Payments { get; set; }
        public DbSet<Refund> Refunds { get; set; }
        public DbSet<PaymentStatus> PaymentStatuses { get; set; }
        public DbSet<Notification> Notifications { get; set; }
        public DbSet<NotificationType> NotificationTypes { get; set; }
        public DbSet<News> News { get; set; }
        public DbSet<Recommendation> Recommendations { get; set; }
        public DbSet<RecommendationFeedback> RecommendationFeedbacks { get; set; }
        public DbSet<SupportRequest> SupportRequests { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.ApplyConfigurationsFromAssembly(typeof(BarberMeDbContext).Assembly);

            base.OnModelCreating(modelBuilder);
        }
    }
}
