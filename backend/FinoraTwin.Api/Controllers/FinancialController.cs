using System.Security.Claims;
using FinoraTwin.Api.DTOs;
using FinoraTwin.Domain.Abstractions;
using FinoraTwin.Domain.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FinoraTwin.Api.Controllers;

[ApiController]
[Authorize]
[Route("api/v1/financial")]
public class FinancialController : ControllerBase
{
    private readonly IBusinessRepository _businesses;
    private readonly IFinancialCalculationService _financial;
    private readonly ILoanRepository _loans;
    private readonly IUnitOfWork _uow;
    private readonly IDateTime _clock;

    public FinancialController(
        IBusinessRepository businesses,
        IFinancialCalculationService financial,
        ILoanRepository loans,
        IUnitOfWork uow,
        IDateTime clock)
    {
        _businesses = businesses;
        _financial = financial;
        _loans = loans;
        _uow = uow;
        _clock = clock;
    }

    [HttpGet("cashflow")]
    public async Task<ActionResult<CashFlowResponse>> CashFlow([FromQuery] DateTime? from, [FromQuery] DateTime? to, CancellationToken ct)
    {
        var businessId = await GetBusinessIdAsync(ct);
        var now = _clock.UtcNow;
        var f = from ?? DateTime.SpecifyKind(new DateTime(now.Year, now.Month, 1).AddMonths(-2), DateTimeKind.Utc);
        var t = to ?? DateTime.SpecifyKind(new DateTime(now.Year, now.Month, 1).AddMonths(1).AddTicks(-1), DateTimeKind.Utc);
        var m = await _financial.CalculateCashFlowAsync(businessId, f, t, ct);
        return new CashFlowResponse(m);
    }

    [HttpGet("health")]
    public async Task<ActionResult<FinancialHealthResponse>> Health(CancellationToken ct)
    {
        var businessId = await GetBusinessIdAsync(ct);
        var h = await _financial.CalculateHealthAsync(businessId, ct);
        var monthlyRevenue = h.MonthlyRevenue;
        var cashBufferMonths = h.CashBufferWeeks / 4.345m;

        var recommendations = new List<string>();
        var alerts = new List<string>();

        if (h.CashBufferWeeks < 4m)
            alerts.Add($"Cash buffer covers only {h.CashBufferWeeks:0.0} weeks of expenses. Aim for at least 12 weeks.");
        else if (h.CashBufferWeeks < 12m)
            recommendations.Add($"Build cash buffer to cover 12 weeks of expenses (currently {h.CashBufferWeeks:0.0} weeks).");

        if (h.MonthlyNet < 0m)
            alerts.Add($"Monthly cash flow is negative ({h.MonthlyNet:0}). Reduce expenses or grow revenue.");
        else if (monthlyRevenue > 0m && h.MonthlyNet / Math.Max(1m, monthlyRevenue) < 0.10m)
            recommendations.Add("Net margin is below 10%. Review expenses and pricing.");

        if (h.OutstandingDebt > 0m && monthlyRevenue > 0m)
        {
            var debtRatio = h.OutstandingDebt / Math.Max(1m, monthlyRevenue * 12m);
            if (debtRatio > 0.50m)
                alerts.Add($"Debt service is {debtRatio:P0} of annual revenue. Prioritize debt reduction.");
            else if (debtRatio > 0.30m)
                recommendations.Add($"Debt service is {debtRatio:P0} of annual revenue. Consider refinancing.");
        }

        if (h.RevenueStabilityScore < 60m)
            recommendations.Add("Revenue is volatile. Diversify income sources or smooth recurring contracts.");

        if (h.ExpenseControlScore < 60m)
            recommendations.Add("Expense ratio is high. Audit recurring costs and cut non-essential spend.");

        if (h.Status == Domain.Enums.HealthStatus.Strong)
            recommendations.Add("Financial health is strong. Consider reinvesting surplus into growth or buffer.");

        return new FinancialHealthResponse(
            h.OverallScore, h.Status,
            h.CashFlowStabilityScore, h.ExpenseControlScore, h.DebtBurdenScore,
            h.CashBufferScore, h.RevenueStabilityScore, h.CashBufferWeeks,
            Math.Round(cashBufferMonths, 2),
            Math.Round(monthlyRevenue, 2),
            h.MonthlyExpenses,
            h.MonthlyNet,
            h.OutstandingDebt,
            h.TotalIncomeAllTime,
            h.TotalExpensesAllTime,
            recommendations,
            alerts);
    }

    [HttpGet("loans")]
    public async Task<ActionResult<IReadOnlyList<LoanDto>>> Loans(CancellationToken ct)
    {
        var businessId = await GetBusinessIdAsync(ct);
        var loans = await _loans.ListAsync(businessId, ct);
        var result = new List<LoanDto>();
        foreach (var l in loans)
        {
            var outstanding = await _loans.TotalOutstandingDebtAsync(businessId, ct);
            result.Add(new LoanDto(l.Id, l.Lender, l.Principal, l.AnnualInterestRate, l.TermMonths, l.StartDate, outstanding));
        }
        return result;
    }

    [HttpPost("loans")]
    public async Task<ActionResult<LoanDto>> CreateLoan([FromBody] CreateLoanRequest req, CancellationToken ct)
    {
        if (req.Principal <= 0 || req.TermMonths <= 0) throw new ArgumentException("Invalid loan terms.");
        var businessId = await GetBusinessIdAsync(ct);
        var loan = new Loan
        {
            Id = Guid.NewGuid(),
            BusinessId = businessId,
            Lender = req.Lender.Trim(),
            Principal = req.Principal,
            AnnualInterestRate = req.AnnualInterestRate,
            TermMonths = req.TermMonths,
            StartDate = req.StartDate,
            CreatedAt = _clock.UtcNow
        };
        await _loans.AddAsync(loan, ct);
        await _uow.SaveChangesAsync(ct);
        var outstanding = await _loans.TotalOutstandingDebtAsync(businessId, ct);
        return new LoanDto(loan.Id, loan.Lender, loan.Principal, loan.AnnualInterestRate, loan.TermMonths, loan.StartDate, outstanding);
    }

    private async Task<Guid> GetBusinessIdAsync(CancellationToken ct)
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? throw new UnauthorizedAccessException();
        var business = await _businesses.GetByUserIdAsync(Guid.Parse(userId), ct)
            ?? throw new KeyNotFoundException("Business not found.");
        return business.Id;
    }
}
