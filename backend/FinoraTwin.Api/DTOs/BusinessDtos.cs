using FinoraTwin.Domain.Enums;

namespace FinoraTwin.Api.DTOs;

public record BusinessDto(
    Guid Id,
    string Name,
    BusinessType Type,
    string Category,
    int StartingYear,
    string Currency,
    decimal MonthlyOpEx,
    decimal CurrentCashBuffer,
    DateTime CreatedAt,
    DateTime UpdatedAt);

public record UpdateBusinessRequest(
    string? Name,
    BusinessType? Type,
    string? Category,
    int? StartingYear,
    string? Currency,
    decimal? MonthlyOpEx,
    decimal? CurrentCashBuffer);
