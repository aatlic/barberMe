using BarberMe.Database.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BarberMe.Database.EntityConfigurations
{
    public class ReviewConfiguration : IEntityTypeConfiguration<Review>
    {
        public void Configure(EntityTypeBuilder<Review> builder)
        {
            builder.HasKey(x => x.ReviewId);

            builder.Property(x => x.Rating).IsRequired();

            builder.ToTable(t =>
            {
                t.HasCheckConstraint(
                    "CK_Review_Rating",
                    "[Rating] BETWEEN 1 AND 5");
            });

            builder.Property(x => x.Comment).HasMaxLength(500);

            builder.HasOne(x => x.Appointment)
                .WithOne(x => x.Review)
                .HasForeignKey<Review>(x => x.AppointmentId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasOne(x => x.Client)
                .WithMany()
                .HasForeignKey(x => x.ClientId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasOne(x => x.Barber)
                .WithMany()
                .HasForeignKey(x => x.BarberId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasIndex(x => x.AppointmentId)
                    .IsUnique();
        }
    }
}
