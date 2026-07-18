using BarberMe.Database.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
namespace BarberMe.Database.EntityConfigurations
{
    public class PaymentConfiguration : IEntityTypeConfiguration<Payment>
    {
        public void Configure(EntityTypeBuilder<Payment> builder)
        {
            builder.HasKey(x => x.PaymentId);

            builder.Property(x => x.Amount)
                .HasColumnType("decimal(18,2)")
                .IsRequired();

            builder.Property(x => x.StripePaymentIntentId)
                .HasMaxLength(200);

            builder.HasOne(x => x.Appointment)
                .WithOne(x => x.Payment)
                .HasForeignKey<Payment>(x => x.AppointmentId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasOne(x => x.PaymentStatus)
                .WithMany(x => x.Payments)
                .HasForeignKey(x => x.PaymentStatusId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.ToTable(t =>
            {
                t.HasCheckConstraint(
                    "CK_Payment_Amount",
                    "[Amount] > 0");
            });
        }
    }
}
