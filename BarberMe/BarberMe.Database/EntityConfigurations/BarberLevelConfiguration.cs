using BarberMe.Database.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BarberMe.Database.EntityConfigurations
{
    public class BarberLevelConfiguration : IEntityTypeConfiguration<BarberLevel>
    {
        public void Configure(EntityTypeBuilder<BarberLevel> builder)
        {
            builder.HasKey(x => x.BarberLevelId);

            builder.Property(x => x.Name)
                .IsRequired()
                .HasMaxLength(30);

            builder.HasData(
                new BarberLevel { BarberLevelId = 1, Name = "Junior" },
                new BarberLevel { BarberLevelId = 2, Name = "Senior" },
                new BarberLevel { BarberLevelId = 3, Name = "Master" }
            );
        }
    }
}
