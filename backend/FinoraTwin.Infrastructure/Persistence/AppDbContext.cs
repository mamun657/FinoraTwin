using FinoraTwin.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace FinoraTwin.Infrastructure.Persistence;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<User> Users => Set<User>();
    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
    public DbSet<Business> Businesses => Set<Business>();
    public DbSet<Transaction> Transactions => Set<Transaction>();
    public DbSet<Loan> Loans => Set<Loan>();
    public DbSet<LoanPayment> LoanPayments => Set<LoanPayment>();
    public DbSet<FinancialSnapshot> FinancialSnapshots => Set<FinancialSnapshot>();
    public DbSet<Simulation> Simulations => Set<Simulation>();
    public DbSet<Recommendation> Recommendations => Set<Recommendation>();
    public DbSet<AuditLog> AuditLogs => Set<AuditLog>();
    public DbSet<Document> Documents => Set<Document>();
    public DbSet<DocumentChunk> DocumentChunks => Set<DocumentChunk>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly);
    }
}
