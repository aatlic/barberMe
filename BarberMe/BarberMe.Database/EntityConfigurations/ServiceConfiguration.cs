using BarberMe.Database.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BarberMe.Database.EntityConfigurations
{
    public class ServiceConfiguration : IEntityTypeConfiguration<Service>
    {
        public void Configure(EntityTypeBuilder<Service> builder)
        {
            builder.HasKey(x => x.ServiceId);

            builder.Property(x => x.Name).IsRequired().HasMaxLength(100);
            builder.Property(x => x.Description).HasMaxLength(500);

            builder.Property(x => x.DefaultPrice)
                .HasColumnType("decimal(18,2)")
                .IsRequired();

            builder.Property(x => x.DefaultDurationMinutes)
                .IsRequired();

            builder.HasData(
                new Service
                {
                    ServiceId = 1,
                    Name = "Haircut",
                    Description = "Classic men's haircut.",
                    DefaultPrice = 25,
                    DefaultDurationMinutes = 30,
                    IsActive = true
                },
                new Service
                {
                    ServiceId = 2,
                    Name = "Beard Trim",
                    Description = "Beard shaping and trimming.",
                    DefaultPrice = 15,
                    DefaultDurationMinutes = 20,
                    IsActive = true
                },
                new Service
                {
                    ServiceId = 3,
                    Name = "Haircut & Beard",
                    Description = "Haircut with beard trimming and styling.",
                    DefaultPrice = 35,
                    DefaultDurationMinutes = 50,
                    IsActive = true
                },
                new Service
                {
                    ServiceId = 4,
                    Name = "Kids Haircut",
                    Description = "Haircut for children.",
                    DefaultPrice = 20,
                    DefaultDurationMinutes = 25,
                    IsActive = true
                }
            );
        }
    }
}
