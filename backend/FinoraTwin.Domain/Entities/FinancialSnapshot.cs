using FinoraTwin.Domain.Enums;

namespace FinoraTwin.Domain.Entities;

public class FinancialSnapshot
{
    public Guid Id { get; set; }
    public Guid BusinessId { get; set; }
    public DateTime PeriodStart { get; set; }
    public DateTime PeriodEnd { get; set; }
    public decimal TotalIncome { get; set; }
    public decimal TotalExpenses { get; set; }
    public decimal NetCashFlow { get; set; }
    public decimal CashBuffer { get; set; }
    public decimal OutstandingDebt { get; set; }
    public decimal HealthScore { get; set; }
    public HealthStatus HealthStatus { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public Business? Business { get; set; }
}
