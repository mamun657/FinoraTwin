using FinoraTwin.Domain.Enums;

namespace FinoraTwin.Api.DTOs;

public record CapitalSimulationRequest(
    decimal RequestedAmount,
    string Purpose,
    int TermMonths,
    decimal AnnualInterestRate,
    decimal SalesChangePercent = 0);

public record CapitalSimulationScenarioDto(
    string Label,
    decimal Amount,
    decimal MonthlyRepayment,
    decimal PercentOfRevenue,
    bool Feasible);

public record CapitalSimulationResponseDto(
    decimal RequestedAmount,
    decimal RecommendedAmount,
    decimal ProjectedRevenue,
    decimal ProjectedExpenses,
    decimal ProjectedCashFlow,
    decimal MonthlyRepaymentEstimate,
    decimal MaximumSustainableAmount,
    decimal ProjectedCashBuffer,
    int RiskScore,
    RiskLevel RiskLevel,
    string Currency,
    IReadOnlyList<string> Notes,
    IReadOnlyList<CapitalSimulationScenarioDto> Scenarios,
    StressTestResponseDto? StressTest,
    DateTime GeneratedAt);

public record StressTestRequest(
    decimal SalesChangePercent,
    decimal ExpenseChangePercent);

public record StressTestResponseDto(
    decimal AdjustedRevenue,
    decimal AdjustedExpenses,
    decimal AdjustedNetCashFlow,
    decimal AdjustedCashBufferWeeks,
    RiskLevel RiskLevel,
    IReadOnlyList<string> Notes);
