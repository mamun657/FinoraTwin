using FinoraTwin.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FinoraTwin.Infrastructure.Persistence.Configurations;

public class UserConfiguration : IEntityTypeConfiguration<User>
{
    public void Configure(EntityTypeBuilder<User> b)
    {
        b.ToTable("users");
        b.HasKey(x => x.Id);
        b.Property(x => x.Id).HasColumnName("id");
        b.Property(x => x.FullName).HasColumnName("full_name").HasMaxLength(200).IsRequired();
        b.Property(x => x.Email).HasColumnName("email").HasMaxLength(320).IsRequired();
        b.HasIndex(x => x.Email).IsUnique();
        b.Property(x => x.PasswordHash).HasColumnName("password_hash").HasMaxLength(255).IsRequired();
        b.Property(x => x.Role).HasColumnName("role").HasConversion<int>().HasDefaultValueSql("0");
        b.HasIndex(x => x.Role);
        b.Property(x => x.CreatedAt).HasColumnName("created_at");
        b.Property(x => x.UpdatedAt).HasColumnName("updated_at");
        b.Property(x => x.LastLoginAt).HasColumnName("last_login_at");
        b.Property(x => x.IsActive).HasColumnName("is_active").HasDefaultValue(true);
    }
}

public class RefreshTokenConfiguration : IEntityTypeConfiguration<RefreshToken>
{
    public void Configure(EntityTypeBuilder<RefreshToken> b)
    {
        b.ToTable("refresh_tokens");
        b.HasKey(x => x.Id);
        b.Property(x => x.Id).HasColumnName("id");
        b.Property(x => x.UserId).HasColumnName("user_id");
        b.Property(x => x.Token).HasColumnName("token").HasMaxLength(255).IsRequired();
        b.HasIndex(x => x.Token).IsUnique();
        b.Property(x => x.ExpiresAt).HasColumnName("expires_at");
        b.Property(x => x.CreatedAt).HasColumnName("created_at");
        b.Property(x => x.RevokedAt).HasColumnName("revoked_at");
        b.Property(x => x.ReplacedByToken).HasColumnName("replaced_by_token").HasMaxLength(255);
        b.HasOne(x => x.User).WithMany(u => u.RefreshTokens).HasForeignKey(x => x.UserId).OnDelete(DeleteBehavior.Cascade);
    }
}
