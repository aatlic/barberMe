using BarberMe.Database.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BarberMe.Database.EntityConfigurations
{
    public class ShopWorkingHoursConfiguration
        : IEntityTypeConfiguration<ShopWorkingHours>
    {
        public void Configure(EntityTypeBuilder<ShopWorkingHours> builder)
        {
            builder.HasKey(x => x.ShopWorkingHoursId);

            builder.Property(x => x.DayOfWeek)
                .IsRequired();

            builder.Property(x => x.StartTime)
                .IsRequired();

            builder.Property(x => x.EndTime)
                .IsRequired();

            builder.Property(x => x.IsWorking)
                .IsRequired();

            builder.HasIndex(x => x.DayOfWeek)
                .IsUnique();

            builder.HasData(
                new ShopWorkingHours
                {
                    ShopWorkingHoursId = 1,
                    DayOfWeek = 1,
                    StartTime = new TimeSpan(8, 0, 0),
                    EndTime = new TimeSpan(20, 0, 0),
                    IsWorking = true
                },
                new ShopWorkingHours
                {
                    ShopWorkingHoursId = 2,
                    DayOfWeek = 2,
                    StartTime = new TimeSpan(8, 0, 0),
                    EndTime = new TimeSpan(20, 0, 0),
                    IsWorking = true
                },
                new ShopWorkingHours
                {
                    ShopWorkingHoursId = 3,
                    DayOfWeek = 3,
                    StartTime = new TimeSpan(8, 0, 0),
                    EndTime = new TimeSpan(20, 0, 0),
                    IsWorking = true
                },
                new ShopWorkingHours
                {
                    ShopWorkingHoursId = 4,
                    DayOfWeek = 4,
                    StartTime = new TimeSpan(8, 0, 0),
                    EndTime = new TimeSpan(20, 0, 0),
                    IsWorking = true
                },
                new ShopWorkingHours
                {
                    ShopWorkingHoursId = 5,
                    DayOfWeek = 5,
                    StartTime = new TimeSpan(8, 0, 0),
                    EndTime = new TimeSpan(20, 0, 0),
                    IsWorking = true
                },
                new ShopWorkingHours
                {
                    ShopWorkingHoursId = 6,
                    DayOfWeek = 6,
                    StartTime = new TimeSpan(8, 0, 0),
                    EndTime = new TimeSpan(16, 0, 0),
                    IsWorking = true
                },
                new ShopWorkingHours
                {
                    ShopWorkingHoursId = 7,
                    DayOfWeek = 0,
                    StartTime = TimeSpan.Zero,
                    EndTime = TimeSpan.Zero,
                    IsWorking = false
                }
            );
        }
    }
}