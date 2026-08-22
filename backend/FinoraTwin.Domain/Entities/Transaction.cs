using FinoraTwin.Domain.Enums;

namespace FinoraTwin.Domain.Entities;

public class Transaction
{
    public Guid Id { get; set; }
    public Guid BusinessId { get; set; }
    public TransactionType Type { get; set; }
    public TransactionCategory Category { get; set; }
    public decimal Amount { get; set; }
    public string Description { get; set; } = string.Empty;
    public DateTime OccurredAt { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    public Business? Business { get; set; }
}
