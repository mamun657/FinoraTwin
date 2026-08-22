using System.Security.Claims;
using FinoraTwin.Api.DTOs;
using FinoraTwin.Domain.Abstractions;
using FinoraTwin.Domain.Entities;
using FinoraTwin.Domain.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FinoraTwin.Api.Controllers;

[ApiController]
[Authorize]
[Route("api/v1/capital")]
public class CapitalController : ControllerBase
{
    private readonly IBusinessRepository _businesses;
    private readonly ICapitalSimulationService _simulation;
    private readonly IStressTestService _stress;

    public CapitalController(IBusinessRepository businesses, ICapitalSimulationService simulation, IStressTestService stress)
    {
        _businesses = businesses;
        _simulation = simulation;
        _stress = stress;
    }

    [HttpPost("simulate")]
    public async Task<ActionResult<CapitalSimulationResponseDto>> Simulate([FromBody] CapitalSimulationRequest req, CancellationToken ct)
    {
        if (req.RequestedAmount <= 0) throw new ArgumentException("Requested amount must be positive.");
        if (req.TermMonths <= 0) throw new ArgumentException("Term months must be positive.");
        var business = await GetBusinessAsync(ct);
        var input = new CapitalSimulationInput(req.RequestedAmount, req.Purpose, req.TermMonths, req.AnnualInterestRate, req.SalesChangePercent);
        var r = await _simulation.SimulateAsync(business.Id, input, ct);

        var scenarios = BuildScenarios(business, req, r);
        var stress = await _stress.RunAsync(business.Id, new StressTestInput(-20m, 0m), ct);
        var stressDto = new StressTestResponseDto(
            stress.AdjustedRevenue, stress.AdjustedExpenses, stress.AdjustedNetCashFlow,
            stress.AdjustedCashBufferWeeks, stress.RiskLevel, stress.Notes);

        var riskScore = (int)Math.Round(MapRiskLevelToScore(r.RiskLevel, scenarios));
        decimal recommendedAmount = r.RecommendedMaxAmount ?? req.RequestedAmount;
        if (recommendedAmount < 0m) recommendedAmount = 0m;

        var notes = new List<string>();
        notes.Add($"Purpose: {(string.IsNullOrWhiteSpace(req.Purpose) ? "Not specified" : req.Purpose)}.");
        notes.Add($"Repayment is {r.MonthlyRepaymentBurden:0} per month for {req.TermMonths} months at {req.AnnualInterestRate}% annual interest.");
        notes.AddRange(r.Reasons);

        return new CapitalSimulationResponseDto(
            RequestedAmount: Math.Round(req.RequestedAmount, 2),
            RecommendedAmount: Math.Round(Math.Max(0m, recommendedAmount), 2),
            ProjectedRevenue: r.ProjectedRevenue,
            ProjectedExpenses: r.ProjectedExpenses,
            ProjectedCashFlow: r.ProjectedCashFlow,
            MonthlyRepaymentEstimate: r.MonthlyRepaymentBurden,
            MaximumSustainableAmount: r.RecommendedMaxAmount ?? req.RequestedAmount,
            ProjectedCashBuffer: r.ProjectedCashBuffer,
            RiskScore: riskScore,
            RiskLevel: r.RiskLevel,
            Currency: business.Currency,
            Notes: notes,
            Scenarios: scenarios,
            StressTest: stressDto,
            GeneratedAt: DateTime.UtcNow);
    }

    [HttpPost("stress-test")]
    public async Task<ActionResult<StressTestResponseDto>> Stress([FromBody] StressTestRequest req, CancellationToken ct)
    {
        var business = await GetBusinessAsync(ct);
        var r = await _stress.RunAsync(business.Id, new StressTestInput(req.SalesChangePercent, req.ExpenseChangePercent), ct);
        return new StressTestResponseDto(
            r.AdjustedRevenue, r.AdjustedExpenses, r.AdjustedNetCashFlow,
            r.AdjustedCashBufferWeeks, r.RiskLevel, r.Notes);
    }

    private static List<CapitalSimulationScenarioDto> BuildScenarios(Business business, CapitalSimulationRequest req, CapitalSimulationResult r)
    {
        var monthlyRev = r.ProjectedRevenue / 12m;
        var conservative = r.RecommendedMinAmount ?? req.RequestedAmount;
        if (conservative > req.RequestedAmount) conservative = req.RequestedAmount;
        var baseAmt = req.RequestedAmount;
        var aggressive = (r.RecommendedMaxAmount ?? req.RequestedAmount) * 1.25m;
        if (aggressive > req.RequestedAmount) aggressive = req.RequestedAmount;

        var scenarios = new List<CapitalSimulationScenarioDto>
        {
            new("Conservative",
                Math.Round(conservative, 2),
                Math.Round(Repayment(conservative, req.TermMonths, req.AnnualInterestRate), 2),
                monthlyRev <= 0 ? 0m : Math.Round(Repayment(conservative, req.TermMonths, req.AnnualInterestRate) / monthlyRev * 100m, 2),
                r.RiskLevel <= Domain.Enums.RiskLevel.Moderate),
            new("Base",
                Math.Round(baseAmt, 2),
                Math.Round(Repayment(baseAmt, req.TermMonths, req.AnnualInterestRate), 2),
                monthlyRev <= 0 ? 0m : Math.Round(Repayment(baseAmt, req.TermMonths, req.AnnualInterestRate) / monthlyRev * 100m, 2),
                r.RiskLevel <= Domain.Enums.RiskLevel.High),
            new("Aggressive",
                Math.Round(aggressive, 2),
                Math.Round(Repayment(aggressive, req.TermMonths, req.AnnualInterestRate), 2),
                monthlyRev <= 0 ? 0m : Math.Round(Repayment(aggressive, req.TermMonths, req.AnnualInterestRate) / monthlyRev * 100m, 2),
                r.RiskLevel <= Domain.Enums.RiskLevel.Moderate)
        };
        return scenarios;
    }

    private static decimal Repayment(decimal amount, int termMonths, decimal ratePct)
    {
        var total = amount * (1m + (ratePct / 100m));
        return total / Math.Max(1, termMonths);
    }

    private static decimal MapRiskLevelToScore(Domain.Enums.RiskLevel level, IReadOnlyList<CapitalSimulationScenarioDto> scenarios)
    {
        var scoreBase = level switch
        {
            Domain.Enums.RiskLevel.Low => 85m,
            Domain.Enums.RiskLevel.Moderate => 65m,
            Domain.Enums.RiskLevel.High => 40m,
            Domain.Enums.RiskLevel.Critical => 15m,
            _ => 50m
        };
        if (scenarios.Count > 0)
        {
            var feasible = scenarios.Count(s => s.Feasible);
            var bonus = (feasible - 1) * 5m;
            scoreBase = Math.Clamp(scoreBase + bonus, 0m, 100m);
        }
        return scoreBase;
    }

    private async Task<Business> GetBusinessAsync(CancellationToken ct)
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? throw new UnauthorizedAccessException();
        return await _businesses.GetByUserIdAsync(Guid.Parse(userId), ct)
            ?? throw new KeyNotFoundException("Business not found.");
    }
}
