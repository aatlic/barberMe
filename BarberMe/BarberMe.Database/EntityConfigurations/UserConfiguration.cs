using BarberMe.Database.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BarberMe.Database.EntityConfigurations
{
    public class UserConfiguration : IEntityTypeConfiguration<User>
    {
        public void Configure(EntityTypeBuilder<User> builder)
        {
            builder.HasKey(x => x.UserId);

            builder.Property(x => x.FirstName).IsRequired().HasMaxLength(50);
            builder.Property(x => x.LastName).IsRequired().HasMaxLength(50);
            builder.Property(x => x.Username).IsRequired().HasMaxLength(50);
            builder.Property(x => x.Email).IsRequired().HasMaxLength(100);
            builder.Property(x => x.PhoneNumber).IsRequired().HasMaxLength(30);
            builder.Property(x => x.PasswordHash).IsRequired();

            builder.HasIndex(x => x.Username).IsUnique();
            builder.HasIndex(x => x.Email).IsUnique();

            builder.HasOne(x => x.Role)
                .WithMany(x => x.Users)
                .HasForeignKey(x => x.RoleId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasOne(x => x.BarberLevel)
                .WithMany(x => x.Users)
                .HasForeignKey(x => x.BarberLevelId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasData(
                new User
                {
                    UserId = 1,
                    FirstName = "Admin",
                    LastName = "Admin",
                    Username = "admin",
                    Email = "admin@barberme.com",
                    PhoneNumber = "000000000",

                    PasswordHash = "$2a$11$3imUFH1O5lE9g7XuS3hZOOUVPwdRz4yQjbw/4pyzVIeXf/ZHTbBUu",

                    RoleId = 1,

                    BarberLevelId = null,

                    FailedLoginAttempts = 0,
                    IsLocked = false,

                    IsActive = true,
                    RequirePasswordChange = false,

                    CreatedAt = new DateTime(2026, 1, 1)
                },
                new User
                {
                    UserId = 2,

                    FirstName = "John",
                    LastName = "Doe",

                    Username = "barber",
                    Email = "barber@barberme.com",
                    PhoneNumber = "061111111",

                    PasswordHash = "$2a$11$3imUFH1O5lE9g7XuS3hZOOUVPwdRz4yQjbw/4pyzVIeXf/ZHTbBUu",

                    RoleId = 2,
                    BarberLevelId = 2, 

                    FailedLoginAttempts = 0,
                    IsLocked = false,

                    IsActive = true,
                    RequirePasswordChange = false,

                    CreatedAt = new DateTime(2026, 1, 1)
                },
                new User
                {
                    UserId = 3,

                    FirstName = "Jane",
                    LastName = "Doe",

                    Username = "client",
                    Email = "client@barberme.com",
                    PhoneNumber = "062222222",

                    PasswordHash = "$2a$11$3imUFH1O5lE9g7XuS3hZOOUVPwdRz4yQjbw/4pyzVIeXf/ZHTbBUu",

                    RoleId = 3,
                    BarberLevelId = null,

                    FailedLoginAttempts = 0,
                    IsLocked = false,

                    IsActive = true,
                    RequirePasswordChange = false,

                    CreatedAt = new DateTime(2026, 1, 1)
                }
            );
        }
    }
}
