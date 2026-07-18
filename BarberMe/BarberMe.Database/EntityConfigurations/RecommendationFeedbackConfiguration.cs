using BarberMe.Database.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BarberMe.Database.EntityConfigurations
{
    public class RecommendationFeedbackConfiguration : IEntityTypeConfiguration<RecommendationFeedback>
    {
        public void Configure(EntityTypeBuilder<RecommendationFeedback> builder)
        {
            builder.HasKey(x => x.RecommendationFeedbackId);

            builder.Property(x => x.Rating)
                .IsRequired();

            builder.Property(x => x.Comment)
                .HasMaxLength(500);

            builder.HasOne(x => x.Recommendation)
                .WithMany(x => x.Feedbacks)
                .HasForeignKey(x => x.RecommendationId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.ToTable(table =>
            {
                table.HasCheckConstraint(
                    "CK_RecommendationFeedback_Rating",
                    "[Rating] BETWEEN 1 AND 5");
            });
        }
    }
}
