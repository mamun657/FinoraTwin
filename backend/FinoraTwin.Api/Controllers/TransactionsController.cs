using System.Security.Claims;
using FinoraTwin.Api.DTOs;
using FinoraTwin.Domain.Abstractions;
using FinoraTwin.Domain.Entities;
using FinoraTwin.Domain.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FinoraTwin.Api.Controllers;

[ApiController]
[Authorize]
[Route("api/v1/transactions")]
public class TransactionsController : ControllerBase
{
    private readonly ITransactionRepository _tx;
    private readonly IBusinessRepository _businesses;
    private readonly IUnitOfWork _uow;
    private readonly IDateTime _clock;
    private readonly IAuditLogger _audit;

    public TransactionsController(
        ITransactionRepository tx,
        IBusinessRepository businesses,
        IUnitOfWork uow,
        IDateTime clock,
        IAuditLogger audit)
    {
        _tx = tx;
        _businesses = businesses;
        _uow = uow;
        _clock = clock;
        _audit = audit;
    }

    [HttpGet]
    public async Task<ActionResult<TransactionsPage>> List(
        [FromQuery] DateTime? from,
        [FromQuery] DateTime? to,
        [FromQuery] TransactionType? type,
        [FromQuery] TransactionCategory? category,
        [FromQuery] string? search,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 50,
        CancellationToken ct = default)
    {
        var businessId = await GetBusinessIdAsync(ct);
        page = Math.Max(1, page);
        pageSize = Math.Clamp(pageSize, 1, 200);
        var (items, total) = await _tx.ListAsync(businessId, from, to, type, category, search, page, pageSize, ct);
        return new TransactionsPage(page, pageSize, total,
            items.Select(t => new TransactionDto(t.Id, t.OccurredAt, t.Type, t.Category, t.Amount, t.Description, t.CreatedAt)).ToList());
    }

    [HttpPost]
    public async Task<ActionResult<TransactionDto>> Create([FromBody] CreateTransactionRequest req, CancellationToken ct)
    {
        if (req.Amount <= 0) throw new ArgumentException("Amount must be positive.");
        var businessId = await GetBusinessIdAsync(ct);
        var entity = new Transaction
        {
            Id = Guid.NewGuid(),
            BusinessId = businessId,
            OccurredAt = req.OccurredAt == default ? _clock.UtcNow : req.OccurredAt,
            Type = req.Type,
            Category = req.Category,
            Amount = req.Amount,
            Description = string.IsNullOrWhiteSpace(req.Description) ? string.Empty : req.Description.Trim(),
            CreatedAt = _clock.UtcNow
        };
        await _tx.AddAsync(entity, ct);
        await _uow.SaveChangesAsync(ct);
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (Guid.TryParse(userId, out var uid))
            await _audit.LogAsync(uid, "transaction_create", "transaction", entity.Id.ToString(),
                $"type={entity.Type};category={entity.Category};amount={entity.Amount}", ct);
        return new TransactionDto(entity.Id, entity.OccurredAt, entity.Type, entity.Category, entity.Amount, entity.Description, entity.CreatedAt);
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id, CancellationToken ct)
    {
        var businessId = await GetBusinessIdAsync(ct);
        var entity = await _tx.GetAsync(businessId, id, ct)
            ?? throw new KeyNotFoundException("Transaction not found.");
        _tx.Remove(entity);
        await _uow.SaveChangesAsync(ct);
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (Guid.TryParse(userId, out var uid))
            await _audit.LogAsync(uid, "transaction_delete", "transaction", entity.Id.ToString(),
                $"type={entity.Type};category={entity.Category};amount={entity.Amount}", ct);
        return NoContent();
    }

    private async Task<Guid> GetBusinessIdAsync(CancellationToken ct)
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? throw new UnauthorizedAccessException();
        var business = await _businesses.GetByUserIdAsync(Guid.Parse(userId), ct)
            ?? throw new KeyNotFoundException("Business not found.");
        return business.Id;
    }
}
