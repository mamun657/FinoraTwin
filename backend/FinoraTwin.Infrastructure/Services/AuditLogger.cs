using FinoraTwin.Domain.Abstractions;
using FinoraTwin.Domain.Entities;
using FinoraTwin.Infrastructure.Persistence;

namespace FinoraTwin.Infrastructure.Services;

public class AuditLogger : IAuditLogger
{
    private readonly AppDbContext _db;
    public AuditLogger(AppDbContext db) => _db = db;

    public async Task LogAsync(Guid? userId, string action, string entity, string? entityId = null, string? metadataJson = null, CancellationToken ct = default)
    {
        _db.AuditLogs.Add(new AuditLog
        {
            UserId = userId,
            Action = action,
            Entity = entity,
            EntityId = entityId,
            MetadataJson = metadataJson
        });
        await _db.SaveChangesAsync(ct);
    }
}
