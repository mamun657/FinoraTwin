namespace FinoraTwin.Api.DTOs;

public record PagedResult<T>(
    IReadOnlyList<T> Items,
    int Page,
    int PageSize,
    int TotalItems,
    int TotalPages);

public record AdminUserListItemDto(
    Guid Id,
    string Email,
    string FullName,
    string Role,
    bool IsActive,
    DateTime CreatedAt,
    DateTime? LastLoginAt,
    bool HasBusiness,
    string? BusinessName);

public record AdminUserDetailDto(
    Guid Id,
    string Email,
    string FullName,
    string Role,
    bool IsActive,
    DateTime CreatedAt,
    DateTime UpdatedAt,
    DateTime? LastLoginAt,
    AdminBusinessSummaryDto? Business,
    int TransactionsCount,
    int LoansCount,
    int SimulationsCount);

public record AdminBusinessSummaryDto(
    Guid Id,
    string Name,
    string Type,
    string Category,
    string Currency,
    int StartingYear,
    DateTime CreatedAt,
    DateTime UpdatedAt);

public record AdminStatsDto(
    int TotalUsers,
    int ActiveUsers,
    int InactiveUsers,
    int AdminUsers,
    int TotalBusinesses,
    int TotalTransactions,
    int TotalLoans,
    int TotalSimulations,
    int UsersLast7Days,
    int UsersLast30Days,
    int LoginsLast7Days,
    int LoginsLast30Days,
    IReadOnlyList<AdminDailyCountDto> RegistrationSeries30d,
    IReadOnlyList<AdminDailyCountDto> LoginSeries30d);

public record AdminDailyCountDto(DateTime Day, int Count);

public record AdminActivityItemDto(
    long Id,
    Guid? UserId,
    string? UserEmail,
    string? UserFullName,
    string Action,
    string Entity,
    string? EntityId,
    string? MetadataJson,
    DateTime CreatedAt);

public record AdminUpdateUserStatusRequest(bool IsActive);

public record AdminActionResponse(bool Success, string Message);

public record AdminUserListQuery(
    string? Search,
    bool? IsActive,
    string? Role,
    int Page = 1,
    int PageSize = 20);

public record AdminActivityQuery(
    string? Search,
    string? Action,
    Guid? UserId,
    int Page = 1,
    int PageSize = 50);
