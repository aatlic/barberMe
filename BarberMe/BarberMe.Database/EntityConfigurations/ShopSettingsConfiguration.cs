using BarberMe.Database.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BarberMe.Database.EntityConfigurations
{
    public class ShopSettingsConfiguration : IEntityTypeConfiguration<ShopSettings>
    {
        public void Configure(EntityTypeBuilder<ShopSettings> builder)
        {
            builder.HasKey(x => x.ShopSettingsId);

            builder.Property(x => x.Name)
                .IsRequired()
                .HasMaxLength(100);

            builder.Property(x => x.Address)
                .IsRequired()
                .HasMaxLength(200);

            builder.Property(x => x.PhoneNumber)
                .IsRequired()
                .HasMaxLength(30);

            builder.Property(x => x.Email)
                .IsRequired()
                .HasMaxLength(100);

            builder.Property(x => x.Description)
                .HasMaxLength(500);

            builder.HasData(
                new ShopSettings
                {
                    ShopSettingsId = 1,
                    Name = "Barber Me",
                    Address = "Not configured",
                    PhoneNumber = "Not configured",
                    Email = "Not configured",
                    Description = null
                }
            );
        }
    }
}