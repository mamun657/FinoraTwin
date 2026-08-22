using FinoraTwin.Domain.Abstractions;
using FinoraTwin.Domain.Entities;
using FinoraTwin.Domain.Enums;
using FinoraTwin.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace FinoraTwin.Infrastructure.Repositories;

public class TransactionRepository : ITransactionRepository
{
    private readonly AppDbContext _db;
    public TransactionRepository(AppDbContext db) => _db = db;

    public Task<Transaction?> GetAsync(Guid businessId, Guid id, CancellationToken ct = default) =>
        _db.Transactions.FirstOrDefaultAsync(t => t.BusinessId == businessId && t.Id == id, ct);

    public async Task<(IReadOnlyList<Transaction> Items, int Total)> ListAsync(
        Guid businessId,
        DateTime? from,
        DateTime? to,
        TransactionType? type,
        TransactionCategory? category,
        string? search,
        int page,
        int pageSize,
        CancellationToken ct = default)
    {
        var q = _db.Transactions.Where(t => t.BusinessId == businessId);
        if (from.HasValue) q = q.Where(t => t.OccurredAt >= from.Value);
        if (to.HasValue) q = q.Where(t => t.OccurredAt <= to.Value);
        if (type.HasValue) q = q.Where(t => t.Type == type.Value);
        if (category.HasValue) q = q.Where(t => t.Category == category.Value);
        if (!string.IsNullOrWhiteSpace(search))
        {
            var s = search.Trim().ToLower();
            q = q.Where(t => t.Description != null && t.Description.ToLower().Contains(s));
        }
        var total = await q.CountAsync(ct);
        var items = await q.OrderByDescending(t => t.OccurredAt)
                           .ThenByDescending(t => t.CreatedAt)
                           .Skip(Math.Max(0, (page - 1) * pageSize))
                           .Take(pageSize)
                           .ToListAsync(ct);
        return (items, total);
    }

    public async Task AddAsync(Transaction transaction, CancellationToken ct = default) =>
        await _db.Transactions.AddAsync(transaction, ct);

    public void Remove(Transaction transaction) => _db.Transactions.Remove(transaction);

    public async Task<decimal> SumIncomeAsync(Guid businessId, DateTime from, DateTime to, CancellationToken ct = default) =>
        await _db.Transactions
            .Where(t => t.BusinessId == businessId && t.Type == TransactionType.Income && t.OccurredAt >= from && t.OccurredAt <= to)
            .SumAsync(t => (decimal?)t.Amount, ct) ?? 0m;

    public async Task<decimal> SumExpenseAsync(Guid businessId, DateTime from, DateTime to, CancellationToken ct = default) =>
        await _db.Transactions
            .Where(t => t.BusinessId == businessId && t.Type == TransactionType.Expense && t.OccurredAt >= from && t.OccurredAt <= to)
            .SumAsync(t => (decimal?)t.Amount, ct) ?? 0m;

    public async Task<decimal> SumAllIncomeAsync(Guid businessId, CancellationToken ct = default) =>
        await _db.Transactions
            .Where(t => t.BusinessId == businessId && t.Type == TransactionType.Income)
            .SumAsync(t => (decimal?)t.Amount, ct) ?? 0m;

    public async Task<decimal> SumAllExpenseAsync(Guid businessId, CancellationToken ct = default) =>
        await _db.Transactions
            .Where(t => t.BusinessId == businessId && t.Type == TransactionType.Expense)
            .SumAsync(t => (decimal?)t.Amount, ct) ?? 0m;

    public async Task<IReadOnlyList<(TransactionCategory Category, decimal Total)>> TopExpenseCategoriesAsync(
        Guid businessId, DateTime from, DateTime to, int top, CancellationToken ct = default)
    {
        var rows = await _db.Transactions
            .Where(t => t.BusinessId == businessId && t.Type == TransactionType.Expense
                && t.OccurredAt >= from && t.OccurredAt <= to)
            .GroupBy(t => t.Category)
            .Select(g => new { Category = g.Key, Total = g.Sum(x => x.Amount) })
            .OrderByDescending(x => x.Total)
            .Take(top)
            .ToListAsync(ct);
        return rows.Select(r => (r.Category, r.Total)).ToList();
    }

    public Task<int> CountGlobalAsync(CancellationToken ct = default) =>
        _db.Transactions.CountAsync(ct);

    public Task<int> CountForBusinessAsync(Guid businessId, CancellationToken ct = default) =>
        _db.Transactions.CountAsync(t => t.BusinessId == businessId, ct);

    public async Task<IReadOnlyList<Transaction>> ListForBusinessAsync(Guid businessId, int top, CancellationToken ct = default) =>
        await _db.Transactions
            .Where(t => t.BusinessId == businessId)
            .OrderByDescending(t => t.OccurredAt)
            .ThenByDescending(t => t.CreatedAt)
            .Take(top)
            .ToListAsync(ct);
}
