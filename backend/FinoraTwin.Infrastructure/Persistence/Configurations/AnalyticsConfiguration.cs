using FinoraTwin.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FinoraTwin.Infrastructure.Persistence.Configurations;

public class FinancialSnapshotConfiguration : IEntityTypeConfiguration<FinancialSnapshot>
{
    public void Configure(EntityTypeBuilder<FinancialSnapshot> b)
    {
        b.ToTable("financial_snapshots");
        b.HasKey(x => x.Id);
        b.Property(x => x.Id).HasColumnName("id");
        b.Property(x => x.BusinessId).HasColumnName("business_id");
        b.Property(x => x.PeriodStart).HasColumnName("period_start");
        b.Property(x => x.PeriodEnd).HasColumnName("period_end");
        b.Property(x => x.TotalIncome).HasColumnName("total_income").HasColumnType("numeric(18,2)");
        b.Property(x => x.TotalExpenses).HasColumnName("total_expenses").HasColumnType("numeric(18,2)");
        b.Property(x => x.NetCashFlow).HasColumnName("net_cash_flow").HasColumnType("numeric(18,2)");
        b.Property(x => x.CashBuffer).HasColumnName("cash_buffer").HasColumnType("numeric(18,2)");
        b.Property(x => x.OutstandingDebt).HasColumnName("outstanding_debt").HasColumnType("numeric(18,2)");
        b.Property(x => x.HealthScore).HasColumnName("health_score").HasColumnType("numeric(6,2)");
        b.Property(x => x.HealthStatus).HasColumnName("health_status").HasConversion<int>();
        b.Property(x => x.CreatedAt).HasColumnName("created_at");
        b.HasOne(x => x.Business).WithMany(b => b.Snapshots).HasForeignKey(x => x.BusinessId).OnDelete(DeleteBehavior.Cascade);
    }
}

public class SimulationConfiguration : IEntityTypeConfiguration<Simulation>
{
    public void Configure(EntityTypeBuilder<Simulation> b)
    {
        b.ToTable("simulations");
        b.HasKey(x => x.Id);
        b.Property(x => x.Id).HasColumnName("id");
        b.Property(x => x.BusinessId).HasColumnName("business_id");
        b.Property(x => x.RequestedAmount).HasColumnName("requested_amount").HasColumnType("numeric(18,2)");
        b.Property(x => x.Purpose).HasColumnName("purpose").HasMaxLength(200);
        b.Property(x => x.RepaymentTermMonths).HasColumnName("repayment_term_months");
        b.Property(x => x.SalesChangePercent).HasColumnName("sales_change_percent").HasColumnType("numeric(8,2)");
        b.Property(x => x.ProjectedRevenue).HasColumnName("projected_revenue").HasColumnType("numeric(18,2)");
        b.Property(x => x.ProjectedExpenses).HasColumnName("projected_expenses").HasColumnType("numeric(18,2)");
        b.Property(x => x.ProjectedCashFlow).HasColumnName("projected_cash_flow").HasColumnType("numeric(18,2)");
        b.Property(x => x.MonthlyRepaymentBurden).HasColumnName("monthly_repayment_burden").HasColumnType("numeric(18,2)");
        b.Property(x => x.ProjectedCashBuffer).HasColumnName("projected_cash_buffer").HasColumnType("numeric(18,2)");
        b.Property(x => x.RecommendedMinAmount).HasColumnName("recommended_min_amount").HasColumnType("numeric(18,2)");
        b.Property(x => x.RecommendedMaxAmount).HasColumnName("recommended_max_amount").HasColumnType("numeric(18,2)");
        b.Property(x => x.RiskLevel).HasColumnName("risk_level").HasConversion<int>();
        b.Property(x => x.ReasonsJson).HasColumnName("reasons_json").HasColumnType("text");
        b.Property(x => x.CreatedAt).HasColumnName("created_at");
        b.HasOne(x => x.Business).WithMany(b => b.Simulations).HasForeignKey(x => x.BusinessId).OnDelete(DeleteBehavior.Cascade);
    }
}

public class RecommendationConfiguration : IEntityTypeConfiguration<Recommendation>
{
    public void Configure(EntityTypeBuilder<Recommendation> b)
    {
        b.ToTable("recommendations");
        b.HasKey(x => x.Id);
        b.Property(x => x.Id).HasColumnName("id");
        b.Property(x => x.BusinessId).HasColumnName("business_id");
        b.Property(x => x.Title).HasColumnName("title").HasMaxLength(200);
        b.Property(x => x.Body).HasColumnName("body").HasMaxLength(2000);
        b.Property(x => x.Severity).HasColumnName("severity").HasMaxLength(20);
        b.Property(x => x.CreatedAt).HasColumnName("created_at");
        b.HasOne(x => x.Business).WithMany().HasForeignKey(x => x.BusinessId).OnDelete(DeleteBehavior.Cascade);
    }
}

public class AuditLogConfiguration : IEntityTypeConfiguration<AuditLog>
{
    public void Configure(EntityTypeBuilder<AuditLog> b)
    {
        b.ToTable("audit_logs");
        b.HasKey(x => x.Id);
        b.Property(x => x.Id).HasColumnName("id").ValueGeneratedOnAdd();
        b.Property(x => x.UserId).HasColumnName("user_id");
        b.Property(x => x.Action).HasColumnName("action").HasMaxLength(100).IsRequired();
        b.Property(x => x.Entity).HasColumnName("entity").HasMaxLength(100).IsRequired();
        b.Property(x => x.EntityId).HasColumnName("entity_id").HasMaxLength(100);
        b.Property(x => x.MetadataJson).HasColumnName("metadata_json").HasColumnType("text");
        b.Property(x => x.CreatedAt).HasColumnName("created_at");
        b.HasIndex(x => x.UserId);
    }
}

public class DocumentConfiguration : IEntityTypeConfiguration<Document>
{
    public void Configure(EntityTypeBuilder<Document> b)
    {
        b.ToTable("documents");
        b.HasKey(x => x.Id);
        b.Property(x => x.Id).HasColumnName("id");
        b.Property(x => x.Title).HasColumnName("title").HasMaxLength(300).IsRequired();
        b.Property(x => x.Source).HasColumnName("source").HasMaxLength(200);
        b.Property(x => x.Tags).HasColumnName("tags").HasMaxLength(500);
        b.Property(x => x.CreatedAt).HasColumnName("created_at");
    }
}

public class DocumentChunkConfiguration : IEntityTypeConfiguration<DocumentChunk>
{
    public void Configure(EntityTypeBuilder<DocumentChunk> b)
    {
        b.ToTable("document_chunks");
        b.HasKey(x => x.Id);
        b.Property(x => x.Id).HasColumnName("id");
        b.Property(x => x.DocumentId).HasColumnName("document_id");
        b.Property(x => x.ChunkIndex).HasColumnName("chunk_index");
        b.Property(x => x.Content).HasColumnName("content").HasColumnType("text");
        b.Property(x => x.Embedding).HasColumnName("embedding").HasColumnType("real[]");
        b.Property(x => x.CreatedAt).HasColumnName("created_at");
        b.HasOne(x => x.Document).WithMany(d => d.Chunks).HasForeignKey(x => x.DocumentId).OnDelete(DeleteBehavior.Cascade);
    }
}
