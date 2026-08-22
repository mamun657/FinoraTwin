using FinoraTwin.Domain.Enums;

namespace FinoraTwin.Domain.Models;

public record CashFlowMetrics(
    decimal TotalIncome,
    decimal TotalExpenses,
    decimal NetCashFlow,
    decimal AvgMonthlyIncome,
    decimal AvgMonthlyExpenses,
    decimal IncomeStdDev,
    decimal ExpenseStdDev);

public record FinancialHealth(
    decimal OverallScore,
    HealthStatus Status,
    decimal CashFlowStabilityScore,
    decimal ExpenseControlScore,
    decimal DebtBurdenScore,
    decimal CashBufferScore,
    decimal RevenueStabilityScore,
    decimal CashBufferWeeks,
    decimal MonthlyRevenue,
    decimal MonthlyNet,
    decimal MonthlyExpenses,
    decimal OutstandingDebt,
    decimal TotalIncomeAllTime,
    decimal TotalExpensesAllTime);

public record CapitalSimulationInput(
    decimal RequestedAmount,
    string Purpose,
    int RepaymentTermMonths,
    decimal AnnualInterestRate,
    decimal SalesChangePercent);

public record CapitalSimulationResult(
    decimal ProjectedRevenue,
    decimal ProjectedExpenses,
    decimal ProjectedCashFlow,
    decimal MonthlyRepaymentBurden,
    decimal ProjectedCashBuffer,
    decimal? RecommendedMinAmount,
    decimal? RecommendedMaxAmount,
    RiskLevel RiskLevel,
    IReadOnlyList<string> Reasons);

public record StressTestInput(
    decimal SalesChangePercent,
    decimal ExpenseChangePercent);

public record StressTestResult(
    decimal AdjustedRevenue,
    decimal AdjustedExpenses,
    decimal AdjustedNetCashFlow,
    decimal AdjustedCashBufferWeeks,
    RiskLevel RiskLevel,
    IReadOnlyList<string> Notes);
