using BarberMe.Database.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BarberMe.Database.EntityConfigurations
{
    public class NewsConfiguration : IEntityTypeConfiguration<News>
    {
        public void Configure(EntityTypeBuilder<News> builder)
        {
            builder.HasKey(x => x.NewsId);

            builder.Property(x => x.Title)
                .IsRequired()
                .HasMaxLength(100);

            builder.Property(x => x.Content)
                .IsRequired()
                .HasMaxLength(2000);
        }
    }
}
