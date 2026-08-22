using FinoraTwin.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FinoraTwin.Infrastructure.Persistence.Configurations;

public class BusinessConfiguration : IEntityTypeConfiguration<Business>
{
    public void Configure(EntityTypeBuilder<Business> b)
    {
        b.ToTable("businesses");
        b.HasKey(x => x.Id);
        b.Property(x => x.Id).HasColumnName("id");
        b.Property(x => x.UserId).HasColumnName("user_id");
        b.Property(x => x.Name).HasColumnName("name").HasMaxLength(200).IsRequired();
        b.Property(x => x.Type).HasColumnName("type").HasConversion<int>();
        b.Property(x => x.Category).HasColumnName("category").HasMaxLength(100).IsRequired();
        b.Property(x => x.StartingYear).HasColumnName("starting_year");
        b.Property(x => x.Currency).HasColumnName("currency").HasMaxLength(8).HasDefaultValue("BDT");
        b.Property(x => x.MonthlyOpEx).HasColumnName("monthly_opex").HasColumnType("numeric(18,2)").HasDefaultValue(0m);
        b.Property(x => x.CurrentCashBuffer).HasColumnName("current_cash_buffer").HasColumnType("numeric(18,2)").HasDefaultValue(0m);
        b.Property(x => x.CreatedAt).HasColumnName("created_at");
        b.Property(x => x.UpdatedAt).HasColumnName("updated_at");
        b.HasOne(x => x.User).WithOne(u => u.Business).HasForeignKey<Business>(x => x.UserId).OnDelete(DeleteBehavior.Cascade);
        b.HasIndex(x => x.UserId).IsUnique();
    }
}

public class TransactionConfiguration : IEntityTypeConfiguration<Transaction>
{
    public void Configure(EntityTypeBuilder<Transaction> b)
    {
        b.ToTable("transactions");
        b.HasKey(x => x.Id);
        b.Property(x => x.Id).HasColumnName("id");
        b.Property(x => x.BusinessId).HasColumnName("business_id");
        b.Property(x => x.Type).HasColumnName("type").HasConversion<int>();
        b.Property(x => x.Category).HasColumnName("category").HasConversion<int>();
        b.Property(x => x.Amount).HasColumnName("amount").HasColumnType("numeric(18,2)");
        b.Property(x => x.Description).HasColumnName("description").HasMaxLength(500).HasDefaultValue(string.Empty);
        b.Property(x => x.OccurredAt).HasColumnName("occurred_at");
        b.Property(x => x.CreatedAt).HasColumnName("created_at");
        b.Property(x => x.UpdatedAt).HasColumnName("updated_at");
        b.HasOne(x => x.Business).WithMany(b => b.Transactions).HasForeignKey(x => x.BusinessId).OnDelete(DeleteBehavior.Cascade);
        b.HasIndex(x => new { x.BusinessId, x.OccurredAt });
        b.HasIndex(x => new { x.BusinessId, x.Type });
    }
}

public class LoanConfiguration : IEntityTypeConfiguration<Loan>
{
    public void Configure(EntityTypeBuilder<Loan> b)
    {
        b.ToTable("loans");
        b.HasKey(x => x.Id);
        b.Property(x => x.Id).HasColumnName("id");
        b.Property(x => x.BusinessId).HasColumnName("business_id");
        b.Property(x => x.Principal).HasColumnName("principal").HasColumnType("numeric(18,2)");
        b.Property(x => x.AnnualInterestRate).HasColumnName("annual_interest_rate").HasColumnType("numeric(8,4)");
        b.Property(x => x.TermMonths).HasColumnName("term_months");
        b.Property(x => x.Lender).HasColumnName("lender").HasMaxLength(200);
        b.Property(x => x.StartDate).HasColumnName("start_date");
        b.Property(x => x.CreatedAt).HasColumnName("created_at");
        b.HasOne(x => x.Business).WithMany(b => b.Loans).HasForeignKey(x => x.BusinessId).OnDelete(DeleteBehavior.Cascade);
    }
}

public class LoanPaymentConfiguration : IEntityTypeConfiguration<LoanPayment>
{
    public void Configure(EntityTypeBuilder<LoanPayment> b)
    {
        b.ToTable("loan_payments");
        b.HasKey(x => x.Id);
        b.Property(x => x.Id).HasColumnName("id");
        b.Property(x => x.LoanId).HasColumnName("loan_id");
        b.Property(x => x.Amount).HasColumnName("amount").HasColumnType("numeric(18,2)");
        b.Property(x => x.PaidAt).HasColumnName("paid_at");
        b.Property(x => x.Notes).HasColumnName("notes").HasMaxLength(500);
        b.HasOne(x => x.Loan).WithMany(l => l.Payments).HasForeignKey(x => x.LoanId).OnDelete(DeleteBehavior.Cascade);
    }
}
