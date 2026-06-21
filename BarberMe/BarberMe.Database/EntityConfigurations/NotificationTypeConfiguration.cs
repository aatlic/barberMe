using BarberMe.Database.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BarberMe.Database.EntityConfigurations
{
    public class NotificationTypeConfiguration : IEntityTypeConfiguration<NotificationType>
    {
        public void Configure(EntityTypeBuilder<NotificationType> builder)
        {
            builder.HasKey(x => x.NotificationTypeId);

            builder.Property(x => x.Name)
                .IsRequired()
                .HasMaxLength(50);

            builder.HasData(
                new NotificationType { NotificationTypeId = 1, Name = "Reservation" },
                new NotificationType { NotificationTypeId = 2, Name = "Reminder" },
                new NotificationType { NotificationTypeId = 3, Name = "Payment" },
                new NotificationType { NotificationTypeId = 4, Name = "News" },
                new NotificationType { NotificationTypeId = 5, Name = "Cancellation" }
            );
        }
    }
}
