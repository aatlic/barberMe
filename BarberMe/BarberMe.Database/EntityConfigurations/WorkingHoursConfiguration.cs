using BarberMe.Database.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BarberMe.Database.EntityConfigurations
{
    public class WorkingHoursConfiguration : IEntityTypeConfiguration<WorkingHours>
    {
        public void Configure(EntityTypeBuilder<WorkingHours> builder)
        {
            builder.HasKey(x => x.WorkingHoursId);

            builder.Property(x => x.DayOfWeek).IsRequired();
            builder.Property(x => x.StartTime).IsRequired();
            builder.Property(x => x.EndTime).IsRequired();

            builder.HasOne(x => x.Barber)
                .WithMany(x => x.WorkingHours)
                .HasForeignKey(x => x.BarberId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasIndex(x => new { x.BarberId, x.DayOfWeek }).IsUnique();

            builder.HasData(

                new WorkingHours
                {
                    WorkingHoursId = 1,
                    BarberId = 2,

                    DayOfWeek = 1,

                    StartTime = new TimeSpan(10, 0, 0),
                    EndTime = new TimeSpan(18, 0, 0),

                    IsWorking = true
                },

                new WorkingHours
                {
                    WorkingHoursId = 2,
                    BarberId = 2,

                    DayOfWeek = 2,

                    StartTime = new TimeSpan(10, 0, 0),
                    EndTime = new TimeSpan(18, 0, 0),

                    IsWorking = true
                },

                new WorkingHours
                {
                    WorkingHoursId = 3,
                    BarberId = 2,

                    DayOfWeek = 3,

                    StartTime = new TimeSpan(10, 0, 0),
                    EndTime = new TimeSpan(18, 0, 0),

                    IsWorking = true
                },

                new WorkingHours
                {
                    WorkingHoursId = 4,
                    BarberId = 2,

                    DayOfWeek = 4,

                    StartTime = new TimeSpan(10, 0, 0),
                    EndTime = new TimeSpan(18, 0, 0),

                    IsWorking = true
                },

                new WorkingHours
                {
                    WorkingHoursId = 5,
                    BarberId = 2,

                    DayOfWeek = 5,

                    StartTime = new TimeSpan(10, 0, 0),
                    EndTime = new TimeSpan(18, 0, 0),

                    IsWorking = true
                },

                new WorkingHours
                {
                    WorkingHoursId = 6,
                    BarberId = 2,

                    DayOfWeek = 6,

                    StartTime = new TimeSpan(10, 0, 0),
                    EndTime = new TimeSpan(14, 0, 0),

                    IsWorking = true
                },

                new WorkingHours
                {
                    WorkingHoursId = 7,
                    BarberId = 2,

                    DayOfWeek = 0,

                    StartTime = new TimeSpan(0, 0, 0),
                    EndTime = new TimeSpan(0, 0, 0),

                    IsWorking = false
                }

            );
        }
    }
}
