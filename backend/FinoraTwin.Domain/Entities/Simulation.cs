using FinoraTwin.Domain.Enums;

namespace FinoraTwin.Domain.Entities;

public class Simulation
{
    public Guid Id { get; set; }
    public Guid BusinessId { get; set; }
    public decimal RequestedAmount { get; set; }
    public string Purpose { get; set; } = string.Empty;
    public int RepaymentTermMonths { get; set; }
    public decimal SalesChangePercent { get; set; }
    public decimal ProjectedRevenue { get; set; }
    public decimal ProjectedExpenses { get; set; }
    public decimal ProjectedCashFlow { get; set; }
    public decimal MonthlyRepaymentBurden { get; set; }
    public decimal ProjectedCashBuffer { get; set; }
    public decimal RecommendedMinAmount { get; set; }
    public decimal RecommendedMaxAmount { get; set; }
    public RiskLevel RiskLevel { get; set; }
    public string ReasonsJson { get; set; } = "[]";
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public Business? Business { get; set; }
}
