using FinoraTwin.Domain.Enums;

namespace FinoraTwin.Domain.Entities;

public class Business
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string Name { get; set; } = string.Empty;
    public BusinessType Type { get; set; }
    public string Category { get; set; } = string.Empty;
    public int StartingYear { get; set; }
    public string Currency { get; set; } = "BDT";
    public decimal MonthlyOpEx { get; set; }
    public decimal CurrentCashBuffer { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    public User? User { get; set; }
    public ICollection<Transaction> Transactions { get; set; } = new List<Transaction>();
    public ICollection<Loan> Loans { get; set; } = new List<Loan>();
    public ICollection<Simulation> Simulations { get; set; } = new List<Simulation>();
    public ICollection<FinancialSnapshot> Snapshots { get; set; } = new List<FinancialSnapshot>();
}
