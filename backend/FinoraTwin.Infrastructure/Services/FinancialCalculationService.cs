using FinoraTwin.Domain.Abstractions;
using FinoraTwin.Domain.Enums;
using FinoraTwin.Domain.Models;
using FinoraTwin.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace FinoraTwin.Infrastructure.Services;

public class FinancialCalculationService : IFinancialCalculationService
{
    private readonly AppDbContext _db;
    private readonly ILoanRepository _loans;

    public FinancialCalculationService(AppDbContext db, ILoanRepository loans)
    {
        _db = db;
        _loans = loans;
    }

    public async Task<CashFlowMetrics> CalculateCashFlowAsync(Guid businessId, DateTime from, DateTime to, CancellationToken ct = default)
    {
        var incomeRows = await _db.Transactions
            .Where(t => t.BusinessId == businessId && t.Type == TransactionType.Income && t.OccurredAt >= from && t.OccurredAt <= to)
            .Select(t => new { t.OccurredAt, t.Amount })
            .ToListAsync(ct);

        var expenseRows = await _db.Transactions
            .Where(t => t.BusinessId == businessId && t.Type == TransactionType.Expense && t.OccurredAt >= from && t.OccurredAt <= to)
            .Select(t => new { t.OccurredAt, t.Amount })
            .ToListAsync(ct);

        var totalIncome = incomeRows.Sum(r => r.Amount);
        var totalExpenses = expenseRows.Sum(r => r.Amount);
        var months = Math.Max(1, (int)Math.Round((to - from).TotalDays / 30.0));
        var avgMonthlyIncome = totalIncome / months;
        var avgMonthlyExpenses = totalExpenses / months;

        var incomeByMonth = incomeRows
            .GroupBy(r => $"{r.OccurredAt.Year}-{r.OccurredAt.Month:00}")
            .ToDictionary(g => g.Key, g => g.Sum(x => x.Amount));
        var incomeValues = incomeByMonth.Values.DefaultIfEmpty(0m).ToList();
        var avgInc = incomeValues.Average();
        var varianceInc = incomeValues.Sum(v => (v - avgInc) * (v - avgInc)) / Math.Max(1, incomeValues.Count);
        var incomeStdDev = (decimal)Math.Sqrt((double)varianceInc);

        var expenseByMonth = expenseRows
            .GroupBy(r => $"{r.OccurredAt.Year}-{r.OccurredAt.Month:00}")
            .ToDictionary(g => g.Key, g => g.Sum(x => x.Amount));
        var expenseValues = expenseByMonth.Values.DefaultIfEmpty(0m).ToList();
        var avgExp = expenseValues.Average();
        var varianceExp = expenseValues.Sum(v => (v - avgExp) * (v - avgExp)) / Math.Max(1, expenseValues.Count);
        var expenseStdDev = (decimal)Math.Sqrt((double)varianceExp);

        return new CashFlowMetrics(
            totalIncome,
            totalExpenses,
            totalIncome - totalExpenses,
            avgMonthlyIncome,
            avgMonthlyExpenses,
            incomeStdDev,
            expenseStdDev);
    }

    public async Task<FinancialHealth> CalculateHealthAsync(Guid businessId, CancellationToken ct = default)
    {
        var now = DateTime.UtcNow;
        var last3Start = DateTime.SpecifyKind(new DateTime(now.Year, now.Month, 1).AddMonths(-2), DateTimeKind.Utc);
        var last3End = DateTime.SpecifyKind(new DateTime(now.Year, now.Month, 1).AddMonths(1).AddTicks(-1), DateTimeKind.Utc);

        var metrics = await CalculateCashFlowAsync(businessId, last3Start, last3End, ct);

        var totalIncomeAllTime = await _db.Transactions
            .Where(t => t.BusinessId == businessId && t.Type == TransactionType.Income)
            .SumAsync(t => (decimal?)t.Amount, ct) ?? 0m;
        var totalExpensesAllTime = await _db.Transactions
            .Where(t => t.BusinessId == businessId && t.Type == TransactionType.Expense)
            .SumAsync(t => (decimal?)t.Amount, ct) ?? 0m;

        // Monthly aggregates: query the current calendar month directly.
        // The 3-month average above dilutes single-month activity (e.g. a single
        // $5k income in an otherwise-empty month shows as ~$1.6k), so we use
        // a separate, focused query for the "this month" figures surfaced in
        // the dashboard. If the month has no activity we fall back to the
        // trailing-3-month average so the UI never shows bogus zeros.
        var monthStart = DateTime.SpecifyKind(new DateTime(now.Year, now.Month, 1), DateTimeKind.Utc);
        var monthEnd = DateTime.SpecifyKind(monthStart.AddMonths(1).AddTicks(-1), DateTimeKind.Utc);
        var monthIncome = await _db.Transactions
            .Where(t => t.BusinessId == businessId && t.Type == TransactionType.Income
                        && t.OccurredAt >= monthStart && t.OccurredAt <= monthEnd)
            .SumAsync(t => (decimal?)t.Amount, ct) ?? 0m;
        var monthExpenses = await _db.Transactions
            .Where(t => t.BusinessId == businessId && t.Type == TransactionType.Expense
                        && t.OccurredAt >= monthStart && t.OccurredAt <= monthEnd)
            .SumAsync(t => (decimal?)t.Amount, ct) ?? 0m;
        var monthIncomeCount = await _db.Transactions
            .CountAsync(t => t.BusinessId == businessId && t.Type == TransactionType.Income
                             && t.OccurredAt >= monthStart && t.OccurredAt <= monthEnd, ct);
        var monthExpenseCount = await _db.Transactions
            .CountAsync(t => t.BusinessId == businessId && t.Type == TransactionType.Expense
                             && t.OccurredAt >= monthStart && t.OccurredAt <= monthEnd, ct);

        var monthlyIncome = monthIncomeCount > 0 ? monthIncome : metrics.AvgMonthlyIncome;
        var monthlyExpensesResolved = monthExpenseCount > 0 ? monthExpenses : metrics.AvgMonthlyExpenses;
        var cashBuffer = Math.Max(0m, totalIncomeAllTime - totalExpensesAllTime);
        var monthlyExpenses = monthlyExpensesResolved;
        // MonthlyNet = current-month net (income - expenses), with fallback to the
        // 3-month average net when the current month has no activity.
        var monthlyNet = monthIncomeCount > 0 || monthExpenseCount > 0
            ? monthIncome - monthExpenses
            : metrics.NetCashFlow;
        var bufferWeeks = monthlyExpenses <= 0 ? 0m : (cashBuffer / monthlyExpenses) * 4.345m;

        var outstandingDebt = await _loans.TotalOutstandingDebtAsync(businessId, ct);

        var netRatio = monthlyIncome <= 0 ? 0m : Clamp01(monthlyNet / (monthlyIncome * 3m));
        var volatilityPenalty = monthlyIncome <= 0 ? 1m : Clamp01(metrics.IncomeStdDev / (monthlyIncome * 3m + 1m));
        var cashFlowStabilityScore = Math.Round(100m * netRatio * (1m - volatilityPenalty * 0.5m), 2);

        var expenseRatio = monthlyIncome <= 0 ? 1m : Clamp01(monthlyExpenses / Math.Max(1m, monthlyIncome));
        var expenseControlScore = Math.Round(100m * (1m - expenseRatio), 2);

        var annualizedIncome = monthlyIncome * 12m;
        var debtRatio = annualizedIncome <= 0 ? 1m : Clamp01(outstandingDebt / Math.Max(1m, annualizedIncome));
        var debtBurdenScore = Math.Round(100m * (1m - debtRatio), 2);

        var bufferScore = Math.Round(Math.Min(100m, Math.Max(0m, (bufferWeeks / 12m) * 100m)), 2);

        var revenueCv = monthlyIncome <= 0 ? 1m : Clamp01(metrics.IncomeStdDev / Math.Max(1m, monthlyIncome * 3m));
        var revenueStabilityScore = Math.Round(100m * (1m - revenueCv), 2);

        var overall = (cashFlowStabilityScore * 0.30m) + (expenseControlScore * 0.25m) + (debtBurdenScore * 0.20m) + (bufferScore * 0.15m) + (revenueStabilityScore * 0.10m);
        overall = Math.Clamp(overall, 0m, 100m);

        var status = overall >= 80m ? HealthStatus.Strong
            : overall >= 60m ? HealthStatus.Healthy
            : overall >= 40m ? HealthStatus.Fair
            : HealthStatus.Weak;

        return new FinancialHealth(
            Math.Round(overall, 2),
            status,
            Math.Round(cashFlowStabilityScore, 2),
            Math.Round(expenseControlScore, 2),
            Math.Round(debtBurdenScore, 2),
            Math.Round(bufferScore, 2),
            Math.Round(revenueStabilityScore, 2),
            Math.Round(bufferWeeks, 2),
            Math.Round(monthlyIncome, 2),
            Math.Round(monthlyNet, 2),
            Math.Round(monthlyExpenses, 2),
            Math.Round(outstandingDebt, 2),
            totalIncomeAllTime,
            totalExpensesAllTime);
    }

    private static decimal Clamp01(decimal v) => Math.Max(0m, Math.Min(1m, v));
}


