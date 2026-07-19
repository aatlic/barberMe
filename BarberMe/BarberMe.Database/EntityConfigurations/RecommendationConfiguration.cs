using BarberMe.Database.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BarberMe.Database.EntityConfigurations
{
    public class RecommendationConfiguration :
        IEntityTypeConfiguration<Recommendation>
    {
        public void Configure(EntityTypeBuilder<Recommendation> builder)
        {
            builder.HasKey(x => x.RecommendationId);

            builder.Property(x => x.Score)
                .HasColumnType("decimal(5,4)")
                .IsRequired();

            builder.Property(x => x.Explanation)
                .IsRequired()
                .HasMaxLength(1000);

            builder.Property(x => x.CreatedAt)
                .IsRequired();

            builder.HasOne(x => x.User)
                .WithMany()
                .HasForeignKey(x => x.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasOne(x => x.BarberService)
                .WithMany()
                .HasForeignKey(x => x.BarberServiceId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasIndex(x => new
            {
                x.UserId,
                x.BarberServiceId,
                x.CreatedAt
            });

            builder.ToTable(table =>
            {
                table.HasCheckConstraint(
                    "CK_Recommendation_Score",
                    "[Score] >= 0 AND [Score] <= 1");
            });
        }
    }
}