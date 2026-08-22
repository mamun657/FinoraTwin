using FinoraTwin.Domain.Abstractions;
using FinoraTwin.Domain.Enums;
using FinoraTwin.Domain.Models;

namespace FinoraTwin.Infrastructure.Services;

public class CapitalSimulationService : ICapitalSimulationService
{
    private readonly IFinancialCalculationService _financial;
    private readonly ILoanRepository _loans;

    public CapitalSimulationService(IFinancialCalculationService financial, ILoanRepository loans)
    {
        _financial = financial;
        _loans = loans;
    }

    public async Task<CapitalSimulationResult> SimulateAsync(Guid businessId, CapitalSimulationInput input, CancellationToken ct = default)
    {
        if (input.RequestedAmount <= 0) throw new ArgumentException("Requested amount must be positive.");
        if (input.RepaymentTermMonths <= 0) throw new ArgumentException("Repayment term must be positive.");

        var health = await _financial.CalculateHealthAsync(businessId, ct);
        var baseline = await _financial.CalculateCashFlowAsync(
            businessId,
            DateTime.SpecifyKind(new DateTime(DateTime.UtcNow.Year, DateTime.UtcNow.Month, 1).AddMonths(-2), DateTimeKind.Utc),
            DateTime.SpecifyKind(new DateTime(DateTime.UtcNow.Year, DateTime.UtcNow.Month, 1).AddMonths(1).AddTicks(-1), DateTimeKind.Utc),
            ct);

        var salesMultiplier = 1m + (input.SalesChangePercent / 100m);
        var projMonthlyRev = baseline.AvgMonthlyIncome * salesMultiplier;
        var projMonthlyExp = baseline.AvgMonthlyExpenses;
        var projMonthlyNet = projMonthlyRev - projMonthlyExp;

        var totalPayable = input.RequestedAmount * (1 + (input.AnnualInterestRate / 100m));
        var monthlyRepayment = totalPayable / input.RepaymentTermMonths;

        var newBuffer = Math.Max(0m, health.CashBufferWeeks * health.MonthlyExpenses - 0m);
        var bufferAfter = Math.Max(0m, newBuffer - monthlyRepayment * 1m); // immediate month 1

        var repaymentToIncome = projMonthlyRev <= 0 ? 1m : monthlyRepayment / projMonthlyRev;
        var debtToIncome = await _loans.TotalOutstandingDebtAsync(businessId, ct) + input.RequestedAmount;
        var annualizedIncome = projMonthlyRev * 12m;
        var debtRatio = annualizedIncome <= 0 ? 1m : Math.Min(1m, debtToIncome / Math.Max(1m, annualizedIncome));

        var reasons = new List<string>();
        RiskLevel risk;

        if (repaymentToIncome > 0.40m) { risk = RiskLevel.Critical; reasons.Add($"Monthly repayment would consume {(repaymentToIncome * 100m):0}% of projected revenue."); }
        else if (repaymentToIncome > 0.25m) { risk = RiskLevel.High; reasons.Add($"Monthly repayment is {(repaymentToIncome * 100m):0}% of projected revenue, which is aggressive."); }
        else if (repaymentToIncome > 0.15m) { risk = RiskLevel.Moderate; reasons.Add($"Monthly repayment is {(repaymentToIncome * 100m):0}% of projected revenue."); }
        else { risk = RiskLevel.Low; reasons.Add("Repayment is a small share of projected revenue."); }

        if (debtRatio > 0.50m) { risk = RiskLevel.Critical; reasons.Add("Total debt would exceed 50% of annualized income."); }
        else if (debtRatio > 0.30m && risk < RiskLevel.High) { risk = RiskLevel.High; reasons.Add("Total debt would exceed 30% of annualized income."); }

        if (bufferAfter < health.MonthlyExpenses * 1m)
        {
            reasons.Add("Cash buffer would drop below one month of operating expenses.");
            if (risk < RiskLevel.High) risk = RiskLevel.High;
        }

        if (input.SalesChangePercent < 0 && risk < RiskLevel.Moderate)
        {
            reasons.Add($"Sales decline scenario of {input.SalesChangePercent}% included.");
            risk = risk == RiskLevel.Low ? RiskLevel.Moderate : risk;
        }

        var safeMonthlyRepayment = projMonthlyRev * 0.25m;
        var safeTotal = safeMonthlyRepayment * input.RepaymentTermMonths;
        var safePrincipal = safeTotal / (1 + (input.AnnualInterestRate / 100m));
        var minRec = Math.Min(input.RequestedAmount, Math.Round(safePrincipal * 0.6m, 0));
        var maxRec = Math.Min(input.RequestedAmount, Math.Round(safePrincipal * 0.9m, 0));

        return new CapitalSimulationResult(
            ProjectedRevenue: Math.Round(projMonthlyRev * 12m, 2),
            ProjectedExpenses: Math.Round(projMonthlyExp * 12m, 2),
            ProjectedCashFlow: Math.Round(projMonthlyNet * 12m, 2),
            MonthlyRepaymentBurden: Math.Round(monthlyRepayment, 2),
            ProjectedCashBuffer: Math.Round(bufferAfter, 2),
            RecommendedMinAmount: Math.Max(0, minRec),
            RecommendedMaxAmount: Math.Max(0, maxRec),
            RiskLevel: risk,
            Reasons: reasons);
    }
}

public class RiskAssessmentService : IRiskAssessmentService
{
    private readonly IFinancialCalculationService _financial;
    private readonly ILoanRepository _loans;

    public RiskAssessmentService(IFinancialCalculationService financial, ILoanRepository loans)
    {
        _financial = financial;
        _loans = loans;
    }

    public async Task<RiskAssessment> AssessAsync(Guid businessId, decimal monthlyRepayment, CancellationToken ct = default)
    {
        var health = await _financial.CalculateHealthAsync(businessId, ct);
        var outstandingDebt = await _loans.TotalOutstandingDebtAsync(businessId, ct);
        var monthlyIncome = health.MonthlyExpenses > 0 ? (health.MonthlyNet + health.MonthlyExpenses) : 0m;

        var debtToIncome = (monthlyIncome * 12m) <= 0 ? 1m :
            Math.Min(1m, outstandingDebt / (monthlyIncome * 12m));
        var repaymentToIncome = monthlyIncome <= 0 ? 1m : Math.Min(1m, monthlyRepayment / monthlyIncome);
        var bufferCoverage = health.MonthlyExpenses <= 0 ? 0m : (health.CashBufferWeeks / 4m);

        RiskLevel level;
        var sum = $"Repayment {(repaymentToIncome * 100m):0}% of monthly income, debt-to-income {(debtToIncome * 100m):0}%.";
        if (repaymentToIncome > 0.40m || debtToIncome > 0.50m) level = RiskLevel.Critical;
        else if (repaymentToIncome > 0.25m || debtToIncome > 0.30m) level = RiskLevel.High;
        else if (repaymentToIncome > 0.15m || debtToIncome > 0.20m) level = RiskLevel.Moderate;
        else level = RiskLevel.Low;

        return new RiskAssessment(debtToIncome, repaymentToIncome, bufferCoverage, level, sum);
    }
}

public class StressTestService : IStressTestService
{
    private readonly IFinancialCalculationService _financial;
    private readonly ILoanRepository _loans;

    public StressTestService(IFinancialCalculationService financial, ILoanRepository loans)
    {
        _financial = financial;
        _loans = loans;
    }

    public async Task<StressTestResult> RunAsync(Guid businessId, StressTestInput input, CancellationToken ct = default)
    {
        var now = DateTime.UtcNow;
        var from = DateTime.SpecifyKind(new DateTime(now.Year, now.Month, 1).AddMonths(-2), DateTimeKind.Utc);
        var to = DateTime.SpecifyKind(new DateTime(now.Year, now.Month, 1).AddMonths(1).AddTicks(-1), DateTimeKind.Utc);
        var baseline = await _financial.CalculateCashFlowAsync(businessId, from, to, ct);
        var debt = await _loans.TotalOutstandingDebtAsync(businessId, ct);

        var salesMult = 1m + (input.SalesChangePercent / 100m);
        var expMult = 1m + (input.ExpenseChangePercent / 100m);

        var adjustedRevenue = baseline.AvgMonthlyIncome * salesMult * 12m;
        var adjustedExpenses = baseline.AvgMonthlyExpenses * expMult * 12m;
        var adjustedNet = adjustedRevenue - adjustedExpenses;

        var health = await _financial.CalculateHealthAsync(businessId, ct);
        var baseBuffer = Math.Max(0m, health.CashBufferWeeks * health.MonthlyExpenses);
        var adjustedMonthlyNet = baseline.AvgMonthlyIncome * salesMult - baseline.AvgMonthlyExpenses * expMult;
        var adjustedBufferWeeks = (adjustedMonthlyNet / 12m) <= 0
            ? 0m
            : Math.Max(0m, health.CashBufferWeeks + (adjustedMonthlyNet * 12m / Math.Max(1m, baseline.AvgMonthlyExpenses)));

        RiskLevel risk;
        if (adjustedNet < 0) risk = RiskLevel.Critical;
        else if (adjustedNet < baseline.AvgMonthlyExpenses * 12m * 0.10m) risk = RiskLevel.High;
        else if (adjustedNet < baseline.AvgMonthlyExpenses * 12m * 0.25m) risk = RiskLevel.Moderate;
        else risk = RiskLevel.Low;

        var notes = new List<string>
        {
            $"Applied {input.SalesChangePercent}% sales change and {input.ExpenseChangePercent}% expense change.",
            $"Projected annual revenue: {adjustedRevenue:0}, projected expenses: {adjustedExpenses:0}.",
            $"Projected annual net cash flow: {adjustedNet:0}."
        };
        if (debt > 0) notes.Add($"Existing outstanding debt: {debt:0}.");

        return new StressTestResult(
            Math.Round(adjustedRevenue, 2),
            Math.Round(adjustedExpenses, 2),
            Math.Round(adjustedNet, 2),
            Math.Round(adjustedBufferWeeks, 2),
            risk,
            notes);
    }
}
