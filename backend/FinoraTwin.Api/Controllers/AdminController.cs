using System.Security.Claims;
using FinoraTwin.Api.DTOs;
using FinoraTwin.Domain.Abstractions;
using FinoraTwin.Domain.Entities;
using FinoraTwin.Domain.Enums;
using FinoraTwin.Infrastructure.Persistence;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace FinoraTwin.Api.Controllers;

[ApiController]
[Authorize(Policy = "Admin")]
[Route("api/v1/admin")]
public class AdminController : ControllerBase
{
    private readonly IUserRepository _users;
    private readonly IAuditLogRepository _auditLogs;
    private readonly IBusinessRepository _businesses;
    private readonly ITransactionRepository _transactions;
    private readonly ILoanRepository _loans;
    private readonly ISimulationRepository _simulations;
    private readonly IAuditLogger _audit;
    private readonly IUnitOfWork _uow;
    private readonly IDateTime _clock;
    private readonly AppDbContext _db;

    public AdminController(
        IUserRepository users,
        IAuditLogRepository auditLogs,
        IBusinessRepository businesses,
        ITransactionRepository transactions,
        ILoanRepository loans,
        ISimulationRepository simulations,
        IAuditLogger audit,
        IUnitOfWork uow,
        IDateTime clock,
        AppDbContext db)
    {
        _users = users;
        _auditLogs = auditLogs;
        _businesses = businesses;
        _transactions = transactions;
        _loans = loans;
        _simulations = simulations;
        _audit = audit;
        _uow = uow;
        _clock = clock;
        _db = db;
    }

    [HttpGet("statistics")]
    public async Task<ActionResult<AdminStatsDto>> Statistics(CancellationToken ct)
    {
        var now = _clock.UtcNow;
        var since7 = now.AddDays(-7);
        var since30 = now.AddDays(-30);
        var from30 = now.AddDays(-30).Date;
        var to30 = now.Date.AddDays(1).AddTicks(-1);

        var totalUsers = await _users.CountAsync(null, ct);
        var activeUsers = await _users.CountAsync(true, ct);
        var inactiveUsers = await _users.CountAsync(false, ct);
        var adminUsers = (await _users.ListAsync(null, true, 1, 200, ct)).Items.Count(u => u.Role == UserRole.Admin);
        var totalBusinesses = await _businesses.CountAsync(ct);
        var totalTransactions = await _transactions.CountGlobalAsync(ct);

        var totalLoans = 0;
        var totalSimulations = 0;
        var businesses = await _businesses.CountAsync(ct);
        _ = businesses;

        var usersLast7 = await _users.CountCreatedSinceAsync(since7, ct);
        var usersLast30 = await _users.CountCreatedSinceAsync(since30, ct);

        var loginMap30 = await _users.GetLastLoginByDayAsync(from30, to30, ct);
        var regMap30 = await _users.GetRegistrationByDayAsync(from30, to30, ct);
        var loginSeries = BuildDailySeries(from30, to30, loginMap30);
        var regSeries = BuildDailySeries(from30, to30, regMap30);

        var logins7 = loginSeries.Where(d => d.Day >= since7.Date).Sum(d => d.Count);
        var logins30 = loginSeries.Sum(d => d.Count);

        return new AdminStatsDto(
            TotalUsers: totalUsers,
            ActiveUsers: activeUsers,
            InactiveUsers: inactiveUsers,
            AdminUsers: adminUsers,
            TotalBusinesses: totalBusinesses,
            TotalTransactions: totalTransactions,
            TotalLoans: totalLoans,
            TotalSimulations: totalSimulations,
            UsersLast7Days: usersLast7,
            UsersLast30Days: usersLast30,
            LoginsLast7Days: logins7,
            LoginsLast30Days: logins30,
            RegistrationSeries30d: regSeries,
            LoginSeries30d: loginSeries);
    }

    [HttpGet("users")]
    public async Task<ActionResult<PagedResult<AdminUserListItemDto>>> ListUsers(
        [FromQuery] string? search,
        [FromQuery] bool? isActive,
        [FromQuery] string? role,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20,
        CancellationToken ct = default)
    {
        var (items, total) = await _users.ListAsync(search, isActive, page, pageSize, ct);
        var filtered = string.IsNullOrWhiteSpace(role)
            ? items
            : items.Where(u => string.Equals(u.Role.ToString(), role, StringComparison.OrdinalIgnoreCase)).ToList();

        var businessMap = new Dictionary<Guid, (string?, bool)>();
        foreach (var u in filtered)
        {
            var b = await _businesses.GetByUserIdAsync(u.Id, ct);
            businessMap[u.Id] = (b?.Name, b != null);
        }

        var dtos = filtered.Select(u => new AdminUserListItemDto(
            u.Id, u.Email, u.FullName, u.Role.ToString(), u.IsActive, u.CreatedAt, u.LastLoginAt,
            businessMap.TryGetValue(u.Id, out var bs) ? bs.Item2 : false,
            businessMap.TryGetValue(u.Id, out var bs2) ? bs2.Item1 : null)).ToList();

        return Paged(dtos, page, pageSize, total);
    }

    [HttpGet("users/{id:guid}")]
    public async Task<ActionResult<AdminUserDetailDto>> GetUser(Guid id, CancellationToken ct)
    {
        var user = await _users.GetByIdAsync(id, ct)
            ?? throw new KeyNotFoundException("User not found.");
        var business = await _businesses.GetByUserIdAsync(user.Id, ct);
        var txCount = business != null ? await _transactions.CountForBusinessAsync(business.Id, ct) : 0;
        var loansCount = business != null ? (await _loans.ListAsync(business.Id, ct)).Count : 0;
        var simsCount = business != null ? (await _simulations.GetRecentAsync(business.Id, 1000, ct)).Count : 0;

        var dto = new AdminUserDetailDto(
            user.Id, user.Email, user.FullName, user.Role.ToString(), user.IsActive,
            user.CreatedAt, user.UpdatedAt, user.LastLoginAt,
            business == null ? null : new AdminBusinessSummaryDto(
                business.Id, business.Name, business.Type.ToString(), business.Category,
                business.Currency, business.StartingYear, business.CreatedAt, business.UpdatedAt),
            txCount, loansCount, simsCount);
        return dto;
    }

    [HttpPost("users/{id:guid}/deactivate")]
    public async Task<ActionResult<AdminActionResponse>> Deactivate(Guid id, CancellationToken ct)
    {
        var currentAdminId = CurrentUserId();
        if (currentAdminId == id)
            throw new InvalidOperationException("You cannot deactivate your own account.");

        var user = await _users.GetByIdAsync(id, ct)
            ?? throw new KeyNotFoundException("User not found.");
        if (!user.IsActive)
            return new AdminActionResponse(true, "User is already inactive.");

        user.IsActive = false;
        user.UpdatedAt = _clock.UtcNow;
        await _uow.SaveChangesAsync(ct);
        await _audit.LogAsync(currentAdminId, "user_deactivate", "user", user.Id.ToString(),
            $"email={user.Email};by_admin={currentAdminId}", ct);

        return new AdminActionResponse(true, "User deactivated.");
    }

    [HttpPost("users/{id:guid}/activate")]
    public async Task<ActionResult<AdminActionResponse>> Activate(Guid id, CancellationToken ct)
    {
        var currentAdminId = CurrentUserId();
        var user = await _users.GetByIdAsync(id, ct)
            ?? throw new KeyNotFoundException("User not found.");
        if (user.IsActive)
            return new AdminActionResponse(true, "User is already active.");

        user.IsActive = true;
        user.UpdatedAt = _clock.UtcNow;
        await _uow.SaveChangesAsync(ct);
        await _audit.LogAsync(currentAdminId, "user_activate", "user", user.Id.ToString(),
            $"email={user.Email};by_admin={currentAdminId}", ct);

        return new AdminActionResponse(true, "User activated.");
    }

    [HttpDelete("users/{id:guid}")]
    public async Task<ActionResult<AdminActionResponse>> DeleteUser(Guid id, CancellationToken ct)
    {
        var currentAdminId = CurrentUserId();
        if (currentAdminId == id)
            throw new InvalidOperationException("You cannot delete your own account.");

        var user = await _users.GetByIdAsync(id, ct)
            ?? throw new KeyNotFoundException("User not found.");

        var deletedEmail = user.Email;

        var business = await _businesses.GetByUserIdAsync(user.Id, ct);
        if (business != null)
        {
            var businessTxns = await _transactions.ListForBusinessAsync(business.Id, 10000, ct);
            if (businessTxns.Count > 0) _db.Transactions.RemoveRange(businessTxns);
            var loans = await _loans.ListAsync(business.Id, ct);
            if (loans.Count > 0) _db.Loans.RemoveRange(loans);
            _db.Businesses.Remove(business);
        }

        var refreshTokens = await _db.RefreshTokens.Where(t => t.UserId == user.Id).ToListAsync(ct);
        if (refreshTokens.Count > 0) _db.RefreshTokens.RemoveRange(refreshTokens);

        var auditEntries = await _db.AuditLogs.Where(a => a.UserId == user.Id).ToListAsync(ct);
        if (auditEntries.Count > 0) _db.AuditLogs.RemoveRange(auditEntries);

        _db.Users.Remove(user);
        await _uow.SaveChangesAsync(ct);

        await _audit.LogAsync(currentAdminId, "user_delete", "user", id.ToString(),
            $"email={deletedEmail};by_admin={currentAdminId};at={_clock.UtcNow:o}", ct);

        return new AdminActionResponse(true, "User permanently deleted.");
    }

    [HttpGet("users/{id:guid}/activity")]
    public async Task<ActionResult<PagedResult<AdminActivityItemDto>>> UserActivity(
        Guid id,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 50,
        CancellationToken ct = default)
    {
        var (rows, totalCount) = await _auditLogs.ListByUserAsync(id, page, pageSize, ct);
        var user = await _users.GetByIdAsync(id, ct);
        var dtos = rows.Select(a => new AdminActivityItemDto(
            a.Id, a.UserId, user?.Email, user?.FullName, a.Action, a.Entity, a.EntityId, a.MetadataJson, a.CreatedAt)).ToList();
        return Paged(dtos, page, pageSize, totalCount);
    }

    [HttpGet("activity")]
    public async Task<ActionResult<PagedResult<AdminActivityItemDto>>> GlobalActivity(
        [FromQuery] string? search,
        [FromQuery] string? action,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 50,
        CancellationToken ct = default)
    {
        var (rows, totalCount) = await _auditLogs.ListAllAsync(search, action, page, pageSize, ct);
        var userIds = rows.Where(a => a.UserId.HasValue).Select(a => a.UserId!.Value).Distinct().ToList();
        var userMap = new Dictionary<Guid, (string, string)>();
        foreach (var uid in userIds)
        {
            var u = await _users.GetByIdAsync(uid, ct);
            if (u != null) userMap[uid] = (u.Email, u.FullName);
        }
        var dtos = rows.Select(a => new AdminActivityItemDto(
            a.Id, a.UserId,
            a.UserId.HasValue && userMap.TryGetValue(a.UserId.Value, out var v) ? v.Item1 : null,
            a.UserId.HasValue && userMap.TryGetValue(a.UserId.Value, out var v2) ? v2.Item2 : null,
            a.Action, a.Entity, a.EntityId, a.MetadataJson, a.CreatedAt)).ToList();
        return Paged(dtos, page, pageSize, totalCount);
    }

    [HttpGet("activity/recent")]
    public async Task<ActionResult<IReadOnlyList<AdminActivityItemDto>>> RecentActivity(
        [FromQuery] int top = 20,
        CancellationToken ct = default)
    {
        top = Math.Clamp(top, 1, 100);
        var rows = await _auditLogs.ListRecentAsync(top, ct);
        var userIds = rows.Where(a => a.UserId.HasValue).Select(a => a.UserId!.Value).Distinct().ToList();
        var userMap = new Dictionary<Guid, (string, string)>();
        foreach (var uid in userIds)
        {
            var u = await _users.GetByIdAsync(uid, ct);
            if (u != null) userMap[uid] = (u.Email, u.FullName);
        }
        return rows.Select(a => new AdminActivityItemDto(
            a.Id, a.UserId,
            a.UserId.HasValue && userMap.TryGetValue(a.UserId.Value, out var v) ? v.Item1 : null,
            a.UserId.HasValue && userMap.TryGetValue(a.UserId.Value, out var v2) ? v2.Item2 : null,
            a.Action, a.Entity, a.EntityId, a.MetadataJson, a.CreatedAt)).ToList();
    }

    private Guid CurrentUserId()
    {
        var v = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return Guid.TryParse(v, out var g) ? g : Guid.Empty;
    }

    private static PagedResult<T> Paged<T>(IReadOnlyList<T> items, int page, int pageSize, int total)
    {
        page = Math.Max(1, page);
        pageSize = Math.Clamp(pageSize, 1, 200);
        var totalPages = total == 0 ? 0 : (int)Math.Ceiling((double)total / pageSize);
        return new PagedResult<T>(items, page, pageSize, total, totalPages);
    }

    private static IReadOnlyList<AdminDailyCountDto> BuildDailySeries(DateTime fromUtc, DateTime toUtc, Dictionary<DateTime, int> source)
    {
        var result = new List<AdminDailyCountDto>();
        var start = fromUtc.Date;
        var end = toUtc.Date;
        for (var d = start; d <= end; d = d.AddDays(1))
        {
            var found = source.TryGetValue(d, out var c) ? c : 0;
            result.Add(new AdminDailyCountDto(d, found));
        }
        return result;
    }
}