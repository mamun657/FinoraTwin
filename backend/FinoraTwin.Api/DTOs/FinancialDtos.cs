using FinoraTwin.Domain.Enums;
using FinoraTwin.Domain.Models;

namespace FinoraTwin.Api.DTOs;

public record CashFlowResponse(CashFlowMetrics Metrics);

public record FinancialHealthResponse(
    decimal OverallScore,
    HealthStatus Status,
    decimal CashFlowStabilityScore,
    decimal ExpenseControlScore,
    decimal DebtBurdenScore,
    decimal CashBufferScore,
    decimal RevenueStabilityScore,
    decimal CashBufferWeeks,
    decimal CashBufferMonths,
    decimal MonthlyRevenue,
    decimal MonthlyExpenses,
    decimal MonthlyNet,
    decimal OutstandingDebt,
    decimal TotalIncomeAllTime,
    decimal TotalExpensesAllTime,
    IReadOnlyList<string> Recommendations,
    IReadOnlyList<string> Alerts);

public record LoanDto(
    Guid Id,
    string Lender,
    decimal Principal,
    decimal AnnualInterestRate,
    int TermMonths,
    DateTime StartDate,
    decimal OutstandingDebt);

public record CreateLoanRequest(
    string Lender,
    decimal Principal,
    decimal AnnualInterestRate,
    int TermMonths,
    DateTime StartDate);
