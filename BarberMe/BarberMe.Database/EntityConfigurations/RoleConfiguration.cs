using BarberMe.Database.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
namespace BarberMe.Database.EntityConfigurations
{
    public class RoleConfiguration : IEntityTypeConfiguration<Role>
    {
        public void Configure(EntityTypeBuilder<Role> builder)
        {
            builder.HasKey(x => x.RoleId);

            builder.Property(x => x.Name)
                .IsRequired()
                .HasMaxLength(30);

            builder.HasData(
                new Role { RoleId = 1, Name = "Admin" },
                new Role { RoleId = 2, Name = "Barber" },
                new Role { RoleId = 3, Name = "Client" }
            );
        }
    }
}
