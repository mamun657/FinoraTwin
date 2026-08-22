using System.Security.Claims;
using FinoraTwin.Api.DTOs;
using FinoraTwin.Domain.Abstractions;
using FinoraTwin.Domain.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FinoraTwin.Api.Controllers;

[ApiController]
[Authorize]
[Route("api/v1/business")]
public class BusinessController : ControllerBase
{
    private readonly IBusinessRepository _businesses;
    private readonly IUnitOfWork _uow;
    private readonly IDateTime _clock;
    private readonly IAuditLogger _audit;

    public BusinessController(IBusinessRepository businesses, IUnitOfWork uow, IDateTime clock, IAuditLogger audit)
    {
        _businesses = businesses;
        _uow = uow;
        _clock = clock;
        _audit = audit;
    }

    [HttpGet]
    public async Task<ActionResult<BusinessDto>> GetMine(CancellationToken ct)
    {
        var business = await GetBusinessAsync(ct);
        return ToDto(business);
    }

    [HttpPut]
    public async Task<ActionResult<BusinessDto>> Update([FromBody] UpdateBusinessRequest req, CancellationToken ct)
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? throw new UnauthorizedAccessException();
        if (!Guid.TryParse(userId, out var uid))
            throw new UnauthorizedAccessException();

        var business = await _businesses.GetByUserIdAsync(uid, ct);
        var isCreate = business == null;

        if (business == null)
        {
            // First-time setup: idempotent create. Require minimum fields.
            if (string.IsNullOrWhiteSpace(req.Name))
                return BadRequest(new { error = "name is required for first-time business setup" });
            if (!req.Type.HasValue)
                return BadRequest(new { error = "type is required for first-time business setup" });
            if (req.MonthlyOpEx is null)
                return BadRequest(new { error = "monthlyOpEx is required for first-time business setup" });

            business = new Business
            {
                Id = Guid.NewGuid(),
                UserId = uid,
                Name = req.Name!.Trim(),
                Type = req.Type!.Value,
                Category = string.IsNullOrWhiteSpace(req.Category) ? "General" : req.Category.Trim(),
                StartingYear = req.StartingYear ?? _clock.UtcNow.Year,
                Currency = string.IsNullOrWhiteSpace(req.Currency) ? "USD" : req.Currency.Trim().ToUpperInvariant(),
                MonthlyOpEx = req.MonthlyOpEx!.Value,
                CurrentCashBuffer = req.CurrentCashBuffer ?? 0m,
                CreatedAt = _clock.UtcNow,
                UpdatedAt = _clock.UtcNow,
            };
            await _businesses.AddAsync(business, ct);
        }
        else
        {
            if (req.Name != null) business.Name = req.Name.Trim();
            if (req.Type.HasValue) business.Type = req.Type.Value;
            if (req.Category != null) business.Category = req.Category.Trim();
            if (req.StartingYear.HasValue) business.StartingYear = req.StartingYear.Value;
            if (req.Currency != null) business.Currency = req.Currency.Trim().ToUpperInvariant();
            if (req.MonthlyOpEx.HasValue) business.MonthlyOpEx = req.MonthlyOpEx.Value;
            if (req.CurrentCashBuffer.HasValue) business.CurrentCashBuffer = req.CurrentCashBuffer.Value;
            business.UpdatedAt = _clock.UtcNow;
            await _uow.SaveChangesAsync(ct);
        }

        await _audit.LogAsync(uid,
            isCreate ? "business_create" : "business_update",
            "business",
            business.Id.ToString(),
            $"name={business.Name};currency={business.Currency};monthly_opex={business.MonthlyOpEx}",
            ct);

        return ToDto(business);
    }

    private async Task<Business> GetBusinessAsync(CancellationToken ct)
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? throw new UnauthorizedAccessException();
        return await _businesses.GetByUserIdAsync(Guid.Parse(userId), ct)
            ?? throw new KeyNotFoundException("Business not found.");
    }

    private static BusinessDto ToDto(Business b) =>
        new(b.Id, b.Name, b.Type, b.Category, b.StartingYear, b.Currency, b.MonthlyOpEx, b.CurrentCashBuffer, b.CreatedAt, b.UpdatedAt);
}
