using BarberMe.Database.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BarberMe.Database.EntityConfigurations
{
    public class PaymentStatusConfiguration : IEntityTypeConfiguration<PaymentStatus>
    {
        public void Configure(EntityTypeBuilder<PaymentStatus> builder)
        {
            builder.HasKey(x => x.PaymentStatusId);

            builder.Property(x => x.Name)
                .IsRequired()
                .HasMaxLength(30);

            builder.HasIndex(x => x.Name)
                .IsUnique();

            builder.HasData(
                new PaymentStatus { PaymentStatusId = 1, Name = "Pending" },
                new PaymentStatus { PaymentStatusId = 2, Name = "Completed" },
                new PaymentStatus { PaymentStatusId = 3, Name = "Refunded" },
                new PaymentStatus { PaymentStatusId = 4, Name = "Failed" }
            );
        }
    }
}
