using BarberMe.Database.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BarberMe.Database.EntityConfigurations
{
    public class BarberServiceConfiguration : IEntityTypeConfiguration<BarberService>
    {
        public void Configure(EntityTypeBuilder<BarberService> builder)
        {
            builder.HasKey(x => x.BarberServiceId);

            builder.Property(x => x.Price)
                .HasColumnType("decimal(18,2)")
                .IsRequired();

            builder.Property(x => x.DurationMinutes)
                .IsRequired();

            builder.HasOne(x => x.Barber)
                .WithMany(x => x.BarberServices)
                .HasForeignKey(x => x.BarberId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasOne(x => x.Service)
                .WithMany(x => x.BarberServices)
                .HasForeignKey(x => x.ServiceId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasIndex(x => new { x.BarberId, x.ServiceId }).IsUnique();

            builder.ToTable(table =>
            {
                table.HasCheckConstraint(
                    "CK_BarberService_Price",
                    "[Price] > 0");

                table.HasCheckConstraint(
                    "CK_BarberService_DurationMinutes",
                    "[DurationMinutes] > 0");
            });

            builder.HasData(

                new BarberService
                {
                    BarberServiceId = 1,

                    BarberId = 2,
                    ServiceId = 1,

                    Price = 25,
                    DurationMinutes = 30,

                    CreatedAt = new DateTime(2026, 1, 1)
                },

                new BarberService
                {
                    BarberServiceId = 2,

                    BarberId = 2,
                    ServiceId = 2,

                    Price = 15,
                    DurationMinutes = 20,

                    CreatedAt = new DateTime(2026, 1, 1)
                },

                new BarberService
                {
                    BarberServiceId = 3,

                    BarberId = 2,
                    ServiceId = 3,

                    Price = 35,
                    DurationMinutes = 50,

                    CreatedAt = new DateTime(2026, 1, 1)
                },

                new BarberService
                {
                    BarberServiceId = 4,

                    BarberId = 2,
                    ServiceId = 4,

                    Price = 20,
                    DurationMinutes = 25,

                    CreatedAt = new DateTime(2026, 1, 1)
                }

            );
        }
    }
}
