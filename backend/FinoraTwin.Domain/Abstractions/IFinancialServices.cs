using FinoraTwin.Domain.Models;

namespace FinoraTwin.Domain.Abstractions;

public interface IFinancialCalculationService
{
    Task<CashFlowMetrics> CalculateCashFlowAsync(Guid businessId, DateTime from, DateTime to, CancellationToken ct = default);
    Task<FinancialHealth> CalculateHealthAsync(Guid businessId, CancellationToken ct = default);
}

public interface ICapitalSimulationService
{
    Task<CapitalSimulationResult> SimulateAsync(Guid businessId, CapitalSimulationInput input, CancellationToken ct = default);
}

public interface IRiskAssessmentService
{
    Task<RiskAssessment> AssessAsync(Guid businessId, decimal monthlyRepayment, CancellationToken ct = default);
}

public record RiskAssessment(
    decimal DebtToIncomeRatio,
    decimal RepaymentToIncomeRatio,
    decimal BufferCoverageRatio,
    Domain.Enums.RiskLevel Level,
    string Summary);

public interface IStressTestService
{
    Task<StressTestResult> RunAsync(Guid businessId, StressTestInput input, CancellationToken ct = default);
}
