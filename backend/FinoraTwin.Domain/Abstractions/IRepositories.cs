using FinoraTwin.Domain.Entities;
using FinoraTwin.Domain.Enums;

namespace FinoraTwin.Domain.Abstractions;

public interface IUserRepository
{
    Task<User?> GetByEmailAsync(string email, CancellationToken ct = default);
    Task<User?> GetByIdAsync(Guid id, CancellationToken ct = default);
    Task AddAsync(User user, CancellationToken ct = default);
    Task<bool> EmailExistsAsync(string email, CancellationToken ct = default);
    Task UpdateAsync(User user, CancellationToken ct = default);
    Task<(IReadOnlyList<User> Items, int Total)> ListAsync(string? search, bool? isActive, int page, int pageSize, CancellationToken ct = default);
    Task<int> CountAsync(bool? isActive, CancellationToken ct = default);
    Task<int> CountCreatedSinceAsync(DateTime sinceUtc, CancellationToken ct = default);
    Task<Dictionary<DateTime, int>> GetRegistrationByDayAsync(DateTime fromUtc, DateTime toUtc, CancellationToken ct = default);
    Task<Dictionary<DateTime, int>> GetLastLoginByDayAsync(DateTime fromUtc, DateTime toUtc, CancellationToken ct = default);
}

public interface IAuditLogRepository
{
    Task<(IReadOnlyList<AuditLog> Items, int Total)> ListByUserAsync(Guid userId, int page, int pageSize, CancellationToken ct = default);
    Task<IReadOnlyList<AuditLog>> ListRecentAsync(int top, CancellationToken ct = default);
    Task<(IReadOnlyList<AuditLog> Items, int Total)> ListAllAsync(string? search, string? action, int page, int pageSize, CancellationToken ct = default);
    Task AddAsync(AuditLog entry, CancellationToken ct = default);
}

public interface IRefreshTokenRepository
{
    Task AddAsync(RefreshToken token, CancellationToken ct = default);
    Task<RefreshToken?> GetAsync(string token, CancellationToken ct = default);
    Task UpdateAsync(RefreshToken token, CancellationToken ct = default);
}

public interface IBusinessRepository
{
    Task<Business?> GetByUserIdAsync(Guid userId, CancellationToken ct = default);
    Task<Business?> GetByIdAsync(Guid id, CancellationToken ct = default);
    Task AddAsync(Business business, CancellationToken ct = default);
    Task UpdateAsync(Business business, CancellationToken ct = default);
    Task<int> CountAsync(CancellationToken ct = default);
}

public interface ITransactionRepository
{
    Task<Transaction?> GetAsync(Guid businessId, Guid id, CancellationToken ct = default);
    Task<(IReadOnlyList<Transaction> Items, int Total)> ListAsync(
        Guid businessId,
        DateTime? from,
        DateTime? to,
        TransactionType? type,
        TransactionCategory? category,
        string? search,
        int page,
        int pageSize,
        CancellationToken ct = default);

    Task AddAsync(Transaction transaction, CancellationToken ct = default);
    void Remove(Transaction transaction);

    Task<decimal> SumIncomeAsync(Guid businessId, DateTime from, DateTime to, CancellationToken ct = default);
    Task<decimal> SumExpenseAsync(Guid businessId, DateTime from, DateTime to, CancellationToken ct = default);
    Task<decimal> SumAllIncomeAsync(Guid businessId, CancellationToken ct = default);
    Task<decimal> SumAllExpenseAsync(Guid businessId, CancellationToken ct = default);
    Task<IReadOnlyList<(TransactionCategory Category, decimal Total)>> TopExpenseCategoriesAsync(
        Guid businessId, DateTime from, DateTime to, int top, CancellationToken ct = default);

    Task<int> CountGlobalAsync(CancellationToken ct = default);
    Task<int> CountForBusinessAsync(Guid businessId, CancellationToken ct = default);
    Task<IReadOnlyList<Transaction>> ListForBusinessAsync(Guid businessId, int top, CancellationToken ct = default);
}

public interface ILoanRepository
{
    Task<IReadOnlyList<Loan>> ListAsync(Guid businessId, CancellationToken ct = default);
    Task<decimal> TotalOutstandingDebtAsync(Guid businessId, CancellationToken ct = default);
    Task AddAsync(Loan loan, CancellationToken ct = default);
}

public interface ISimulationRepository
{
    Task AddAsync(Simulation simulation, CancellationToken ct = default);
    Task<IReadOnlyList<Simulation>> GetRecentAsync(Guid businessId, int top, CancellationToken ct = default);
}

public interface IUnitOfWork
{
    Task<int> SaveChangesAsync(CancellationToken ct = default);
}
