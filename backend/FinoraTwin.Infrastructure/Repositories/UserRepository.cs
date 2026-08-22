using FinoraTwin.Domain.Abstractions;
using FinoraTwin.Domain.Entities;
using FinoraTwin.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace FinoraTwin.Infrastructure.Repositories;

public class UserRepository : IUserRepository
{
    private readonly AppDbContext _db;
    public UserRepository(AppDbContext db) => _db = db;

    public Task<User?> GetByEmailAsync(string email, CancellationToken ct = default) =>
        _db.Users.FirstOrDefaultAsync(u => u.Email.ToLower() == email.ToLower(), ct);

    public Task<User?> GetByIdAsync(Guid id, CancellationToken ct = default) =>
        _db.Users.FirstOrDefaultAsync(u => u.Id == id, ct);

    public async Task AddAsync(User user, CancellationToken ct = default) =>
        await _db.Users.AddAsync(user, ct);

    public Task UpdateAsync(User user, CancellationToken ct = default)
    {
        _db.Users.Update(user);
        return Task.CompletedTask;
    }

    public Task<bool> EmailExistsAsync(string email, CancellationToken ct = default) =>
        _db.Users.AnyAsync(u => u.Email.ToLower() == email.ToLower(), ct);

    public async Task<(IReadOnlyList<User> Items, int Total)> ListAsync(string? search, bool? isActive, int page, int pageSize, CancellationToken ct = default)
    {
        page = Math.Max(1, page);
        pageSize = Math.Clamp(pageSize, 1, 200);
        var q = _db.Users.AsQueryable();
        if (isActive.HasValue) q = q.Where(u => u.IsActive == isActive.Value);
        if (!string.IsNullOrWhiteSpace(search))
        {
            var s = search.Trim().ToLower();
            q = q.Where(u => u.Email.ToLower().Contains(s) || u.FullName.ToLower().Contains(s));
        }
        var total = await q.CountAsync(ct);
        var items = await q.OrderByDescending(u => u.CreatedAt)
                           .Skip((page - 1) * pageSize)
                           .Take(pageSize)
                           .ToListAsync(ct);
        return (items, total);
    }

    public Task<int> CountAsync(bool? isActive, CancellationToken ct = default)
    {
        var q = _db.Users.AsQueryable();
        if (isActive.HasValue) q = q.Where(u => u.IsActive == isActive.Value);
        return q.CountAsync(ct);
    }

    public Task<int> CountCreatedSinceAsync(DateTime sinceUtc, CancellationToken ct = default) =>
        _db.Users.CountAsync(u => u.CreatedAt >= sinceUtc, ct);

    public async Task<Dictionary<DateTime, int>> GetRegistrationByDayAsync(DateTime fromUtc, DateTime toUtc, CancellationToken ct = default)
    {
        var rows = await _db.Users
            .Where(u => u.CreatedAt >= fromUtc && u.CreatedAt <= toUtc)
            .GroupBy(u => u.CreatedAt.Date)
            .Select(g => new { Day = g.Key, Count = g.Count() })
            .ToListAsync(ct);
        return rows.ToDictionary(r => r.Day, r => r.Count);
    }

    public async Task<Dictionary<DateTime, int>> GetLastLoginByDayAsync(DateTime fromUtc, DateTime toUtc, CancellationToken ct = default)
    {
        var rows = await _db.Users
            .Where(u => u.LastLoginAt != null && u.LastLoginAt >= fromUtc && u.LastLoginAt <= toUtc)
            .GroupBy(u => u.LastLoginAt!.Value.Date)
            .Select(g => new { Day = g.Key, Count = g.Count() })
            .ToListAsync(ct);
        return rows.ToDictionary(r => r.Day, r => r.Count);
    }
}

public class RefreshTokenRepository : IRefreshTokenRepository
{
    private readonly AppDbContext _db;
    private readonly IDateTime _clock;
    public RefreshTokenRepository(AppDbContext db, IDateTime clock) { _db = db; _clock = clock; }

    public async Task AddAsync(RefreshToken token, CancellationToken ct = default) =>
        await _db.RefreshTokens.AddAsync(token, ct);

    public Task<RefreshToken?> GetAsync(string token, CancellationToken ct = default) =>
        _db.RefreshTokens.FirstOrDefaultAsync(t => t.Token == token, ct);

    public async Task UpdateAsync(RefreshToken token, CancellationToken ct = default)
    {
        if (token.RevokedAt == null) token.RevokedAt = _clock.UtcNow;
        _db.RefreshTokens.Update(token);
        await Task.CompletedTask;
    }
}

public class BusinessRepository : IBusinessRepository
{
    private readonly AppDbContext _db;
    public BusinessRepository(AppDbContext db) => _db = db;

    public Task<Business?> GetByUserIdAsync(Guid userId, CancellationToken ct = default) =>
        _db.Businesses.FirstOrDefaultAsync(b => b.UserId == userId, ct);

    public Task<Business?> GetByIdAsync(Guid id, CancellationToken ct = default) =>
        _db.Businesses.FirstOrDefaultAsync(b => b.Id == id, ct);

    public async Task AddAsync(Business business, CancellationToken ct = default) =>
        await _db.Businesses.AddAsync(business, ct);

    public Task UpdateAsync(Business business, CancellationToken ct = default) =>
        Task.FromResult(_db.Businesses.Update(business));

    public Task<int> CountAsync(CancellationToken ct = default) =>
        _db.Businesses.CountAsync(ct);
}

public class LoanRepository : ILoanRepository
{
    private readonly AppDbContext _db;
    public LoanRepository(AppDbContext db) => _db = db;

    public async Task<IReadOnlyList<Loan>> ListAsync(Guid businessId, CancellationToken ct = default) =>
        await _db.Loans.Where(l => l.BusinessId == businessId).ToListAsync(ct);

    public async Task<decimal> TotalOutstandingDebtAsync(Guid businessId, CancellationToken ct = default)
    {
        var loans = await _db.Loans.Where(l => l.BusinessId == businessId).ToListAsync(ct);
        if (loans.Count == 0) return 0m;
        var payments = await _db.LoanPayments
            .Where(p => loans.Select(l => l.Id).Contains(p.LoanId))
            .GroupBy(p => p.LoanId)
            .Select(g => new { LoanId = g.Key, Paid = g.Sum(x => x.Amount) })
            .ToListAsync(ct);
        decimal outstanding = 0m;
        foreach (var l in loans)
        {
            var paid = payments.FirstOrDefault(p => p.LoanId == l.Id)?.Paid ?? 0m;
            var totalOwed = l.Principal * (1 + (l.AnnualInterestRate / 100m));
            var remaining = totalOwed - paid;
            if (remaining > 0) outstanding += remaining;
        }
        return outstanding;
    }

    public async Task AddAsync(Loan loan, CancellationToken ct = default) =>
        await _db.Loans.AddAsync(loan, ct);
}

public class SimulationRepository : ISimulationRepository
{
    private readonly AppDbContext _db;
    public SimulationRepository(AppDbContext db) => _db = db;

    public async Task AddAsync(Simulation simulation, CancellationToken ct = default) =>
        await _db.Simulations.AddAsync(simulation, ct);

    public async Task<IReadOnlyList<Simulation>> GetRecentAsync(Guid businessId, int top, CancellationToken ct = default) =>
        await _db.Simulations
            .Where(s => s.BusinessId == businessId)
            .OrderByDescending(s => s.CreatedAt)
            .Take(top)
            .ToListAsync(ct);
}

public class AuditLogRepository : IAuditLogRepository
{
    private readonly AppDbContext _db;
    public AuditLogRepository(AppDbContext db) => _db = db;

    public async Task<(IReadOnlyList<AuditLog> Items, int Total)> ListByUserAsync(Guid userId, int page, int pageSize, CancellationToken ct = default)
    {
        page = Math.Max(1, page);
        pageSize = Math.Clamp(pageSize, 1, 200);
        var q = _db.AuditLogs.Where(a => a.UserId == userId);
        var total = await q.CountAsync(ct);
        var items = await q.OrderByDescending(a => a.CreatedAt)
                           .Skip((page - 1) * pageSize)
                           .Take(pageSize)
                           .ToListAsync(ct);
        return (items, total);
    }

    public async Task<IReadOnlyList<AuditLog>> ListRecentAsync(int top, CancellationToken ct = default) =>
        await _db.AuditLogs
            .OrderByDescending(a => a.CreatedAt)
            .Take(top)
            .ToListAsync(ct);

    public async Task<(IReadOnlyList<AuditLog> Items, int Total)> ListAllAsync(string? search, string? action, int page, int pageSize, CancellationToken ct = default)
    {
        page = Math.Max(1, page);
        pageSize = Math.Clamp(pageSize, 1, 200);
        var q = _db.AuditLogs.AsQueryable();
        if (!string.IsNullOrWhiteSpace(action))
        {
            var a = action.Trim();
            q = q.Where(x => x.Action == a);
        }
        if (!string.IsNullOrWhiteSpace(search))
        {
            var s = search.Trim().ToLower();
            q = q.Where(x =>
                (x.Entity != null && x.Entity.ToLower().Contains(s)) ||
                (x.EntityId != null && x.EntityId.ToLower().Contains(s)) ||
                (x.MetadataJson != null && x.MetadataJson.ToLower().Contains(s)));
        }
        var total = await q.CountAsync(ct);
        var items = await q.OrderByDescending(x => x.CreatedAt)
                           .Skip((page - 1) * pageSize)
                           .Take(pageSize)
                           .ToListAsync(ct);
        return (items, total);
    }

    public async Task AddAsync(AuditLog entry, CancellationToken ct = default) =>
        await _db.AuditLogs.AddAsync(entry, ct);
}
