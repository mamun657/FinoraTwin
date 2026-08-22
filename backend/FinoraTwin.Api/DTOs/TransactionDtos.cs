using FinoraTwin.Domain.Enums;

namespace FinoraTwin.Api.DTOs;

public record TransactionDto(
    Guid Id,
    DateTime OccurredAt,
    TransactionType Type,
    TransactionCategory Category,
    decimal Amount,
    string? Description,
    DateTime CreatedAt);

public record CreateTransactionRequest(
    DateTime OccurredAt,
    TransactionType Type,
    TransactionCategory Category,
    decimal Amount,
    string? Description);

public record TransactionsPage(int Page, int PageSize, int Total, IReadOnlyList<TransactionDto> Items);
