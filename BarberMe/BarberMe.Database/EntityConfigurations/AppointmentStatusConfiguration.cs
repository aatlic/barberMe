using BarberMe.Database.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BarberMe.Database.EntityConfigurations
{
    public class AppointmentStatusConfiguration : IEntityTypeConfiguration<AppointmentStatus>
    {
        public void Configure(EntityTypeBuilder<AppointmentStatus> builder)
        {
            builder.HasKey(x => x.AppointmentStatusId);

            builder.Property(x => x.Name)
                .IsRequired()
                .HasMaxLength(30);

            builder.HasData(
                new AppointmentStatus { AppointmentStatusId = 1, Name = "Pending" },
                new AppointmentStatus { AppointmentStatusId = 2, Name = "Confirmed" },
                new AppointmentStatus { AppointmentStatusId = 3, Name = "Cancelled" },
                new AppointmentStatus { AppointmentStatusId = 4, Name = "Completed" }
            );
        }
    }
}
