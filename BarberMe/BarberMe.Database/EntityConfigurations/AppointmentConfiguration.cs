using BarberMe.Database.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BarberMe.Database.EntityConfigurations
{
    public class AppointmentConfiguration : IEntityTypeConfiguration<Appointment>
    {
        public void Configure(EntityTypeBuilder<Appointment> builder)
        {
            builder.HasKey(x => x.AppointmentId);

            builder.Property(x => x.StartDateTime).IsRequired();
            builder.Property(x => x.EndDateTime).IsRequired();
            builder.Property(x => x.CancellationReason).HasMaxLength(500);

            builder.HasOne(x => x.Client)
                .WithMany()
                .HasForeignKey(x => x.ClientId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasOne(x => x.Barber)
                .WithMany()
                .HasForeignKey(x => x.BarberId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasOne(x => x.BarberService)
                .WithMany()
                .HasForeignKey(x => x.BarberServiceId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasOne(x => x.AppointmentStatus)
                .WithMany(x => x.Appointments)
                .HasForeignKey(x => x.AppointmentStatusId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasOne(x => x.ConfirmedBy)
                .WithMany()
                .HasForeignKey(x => x.ConfirmedById)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasOne(x => x.CancelledBy)
                .WithMany()
                .HasForeignKey(x => x.CancelledById)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasOne(x => x.CompletedBy)
                .WithMany()
                .HasForeignKey(x => x.CompletedById)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasIndex(x => new { x.BarberId, x.StartDateTime, x.EndDateTime });
        }
    }
}
