using FinoraTwin.Domain.Enums;

namespace FinoraTwin.Domain.Abstractions;

public interface IPasswordHasher
{
    string Hash(string password);
    bool Verify(string password, string hash);
}

public interface ITokenService
{
    (string Token, DateTime ExpiresAt) CreateAccessToken(Guid userId, string email, string fullName, UserRole role);
    string GenerateRefreshToken();
    DateTime GetRefreshTokenExpiry();
}

public interface IDateTime
{
    DateTime UtcNow { get; }
}

public interface IAuditLogger
{
    Task LogAsync(Guid? userId, string action, string entity, string? entityId = null, string? metadataJson = null, CancellationToken ct = default);
}

public interface IGroqClient
{
    Task<string> ChatAsync(IReadOnlyList<GroqMessage> messages, IReadOnlyList<GroqToolDefinition> tools, CancellationToken ct = default);
    Task<string> ChatWithDispatcherAsync(IReadOnlyList<GroqMessage> messages, IReadOnlyList<GroqToolDefinition> tools, object dispatcher, CancellationToken ct = default);
}

public record GroqMessage(string Role, string Content);

public record GroqToolDefinition(string Name, string Description, IReadOnlyDictionary<string, object> Parameters);
