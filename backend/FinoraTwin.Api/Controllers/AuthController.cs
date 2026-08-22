using System.Security.Claims;
using FinoraTwin.Api.DTOs;
using FinoraTwin.Domain.Abstractions;
using FinoraTwin.Domain.Entities;
using FinoraTwin.Domain.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FinoraTwin.Api.Controllers;

[ApiController]
[Route("api/v1/auth")]
public class AuthController : ControllerBase
{
    private readonly IUserRepository _users;
    private readonly IRefreshTokenRepository _tokens;
    private readonly IBusinessRepository _businesses;
    private readonly IPasswordHasher _hasher;
    private readonly ITokenService _tokensSvc;
    private readonly IUnitOfWork _uow;
    private readonly IAuditLogger _audit;
    private readonly IDateTime _clock;

    public AuthController(
        IUserRepository users,
        IRefreshTokenRepository tokens,
        IBusinessRepository businesses,
        IPasswordHasher hasher,
        ITokenService tokensSvc,
        IUnitOfWork uow,
        IAuditLogger audit,
        IDateTime clock)
    {
        _users = users;
        _tokens = tokens;
        _businesses = businesses;
        _hasher = hasher;
        _tokensSvc = tokensSvc;
        _uow = uow;
        _audit = audit;
        _clock = clock;
    }

    [HttpPost("register")]
    public async Task<ActionResult<AuthResponse>> Register([FromBody] RegisterRequest req, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(req.Email) || string.IsNullOrWhiteSpace(req.Password) || string.IsNullOrWhiteSpace(req.FullName))
            throw new ArgumentException("Email, password and full name are required.");
        if (req.Password.Length < 8)
            throw new ArgumentException("Password must be at least 8 characters.");

        var email = req.Email.Trim().ToLowerInvariant();
        if (await _users.EmailExistsAsync(email, ct))
            throw new InvalidOperationException("Email already registered.");

        var user = new User
        {
            Id = Guid.NewGuid(),
            Email = email,
            FullName = req.FullName.Trim(),
            PasswordHash = _hasher.Hash(req.Password),
            Role = UserRole.User,
            IsActive = true,
            CreatedAt = _clock.UtcNow,
            UpdatedAt = _clock.UtcNow
        };
        await _users.AddAsync(user, ct);

        var businessName = string.IsNullOrWhiteSpace(req.BusinessName) ? $"{user.FullName}'s Business" : req.BusinessName.Trim();
        var business = new Business
        {
            Id = Guid.NewGuid(),
            UserId = user.Id,
            Name = businessName,
            Type = BusinessType.Other,
            Category = "General",
            StartingYear = DateTime.UtcNow.Year,
            Currency = "USD",
            MonthlyOpEx = 0m,
            CurrentCashBuffer = 0m,
            CreatedAt = _clock.UtcNow,
            UpdatedAt = _clock.UtcNow
        };
        await _businesses.AddAsync(business, ct);
        await _uow.SaveChangesAsync(ct);

        await _audit.LogAsync(user.Id, "register", "user", user.Id.ToString(), null, ct);
        return await IssueAsync(user, ct);
    }

    [HttpPost("login")]
    public async Task<ActionResult<AuthResponse>> Login([FromBody] LoginRequest req, CancellationToken ct)
    {
        var email = req.Email.Trim().ToLowerInvariant();
        var user = await _users.GetByEmailAsync(email, ct)
            ?? throw new UnauthorizedAccessException("Invalid credentials.");
        if (!_hasher.Verify(req.Password, user.PasswordHash))
            throw new UnauthorizedAccessException("Invalid credentials.");
        if (!user.IsActive)
            throw new UnauthorizedAccessException("Account is deactivated.");

        user.LastLoginAt = _clock.UtcNow;
        user.UpdatedAt = _clock.UtcNow;
        await _users.UpdateAsync(user, ct);

        return await IssueAsync(user, ct);
    }

    [HttpPost("refresh")]
    public async Task<ActionResult<AuthResponse>> Refresh([FromBody] RefreshRequest req, CancellationToken ct)
    {
        var existing = await _tokens.GetAsync(req.RefreshToken, ct)
            ?? throw new UnauthorizedAccessException("Invalid refresh token.");
        if (existing.ExpiresAt <= _clock.UtcNow)
            throw new UnauthorizedAccessException("Refresh token expired.");
        if (existing.RevokedAt != null)
            throw new UnauthorizedAccessException("Refresh token revoked.");

        var user = await _users.GetByIdAsync(existing.UserId, ct)
            ?? throw new UnauthorizedAccessException("User not found.");

        existing.RevokedAt = _clock.UtcNow;
        existing.ReplacedByToken = Guid.NewGuid().ToString("N");
        await _uow.SaveChangesAsync(ct);

        return await IssueAsync(user, ct);
    }

    [Authorize]
    [HttpPost("logout")]
    public async Task<IActionResult> Logout([FromBody] RefreshRequest req, CancellationToken ct)
    {
        var existing = await _tokens.GetAsync(req.RefreshToken, ct);
        if (existing != null)
        {
            existing.RevokedAt = _clock.UtcNow;
            await _uow.SaveChangesAsync(ct);
        }
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (Guid.TryParse(userId, out var uid))
            await _audit.LogAsync(uid, "logout", "user", uid.ToString(), null, ct);
        return NoContent();
    }

    [Authorize]
    [HttpGet("me")]
    public async Task<ActionResult<UserDto>> Me(CancellationToken ct)
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? throw new UnauthorizedAccessException();
        var user = await _users.GetByIdAsync(Guid.Parse(userId), ct)
            ?? throw new KeyNotFoundException("User not found.");
        return ToDto(user);
    }

    [HttpPost("forgot-password")]
    public async Task<ActionResult<ForgotPasswordResponse>> ForgotPassword([FromBody] ForgotPasswordRequest req, CancellationToken ct)
    {
        var email = (req.Email ?? string.Empty).Trim().ToLowerInvariant();
        var user = await _users.GetByEmailAsync(email, ct);
        if (user != null)
        {
            var token = Guid.NewGuid().ToString("N");
            await _audit.LogAsync(user.Id, "password_reset_requested", "user", user.Id.ToString(),
                $"reset_token={token}", ct);
        }
        return new ForgotPasswordResponse(email, true,
            "If an account exists for that email, password reset instructions have been generated.");
    }

    private async Task<AuthResponse> IssueAsync(User user, CancellationToken ct)
    {
        var (access, accessExpires) = _tokensSvc.CreateAccessToken(user.Id, user.Email, user.FullName, user.Role);
        var refresh = _tokensSvc.GenerateRefreshToken();
        await _tokens.AddAsync(new RefreshToken
        {
            Id = Guid.NewGuid(),
            UserId = user.Id,
            Token = refresh,
            ExpiresAt = _tokensSvc.GetRefreshTokenExpiry(),
            CreatedAt = _clock.UtcNow
        }, ct);
        await _uow.SaveChangesAsync(ct);
        await _audit.LogAsync(user.Id, "login", "user", user.Id.ToString(), null, ct);
        return new AuthResponse(access, refresh, accessExpires, ToDto(user));
    }

    private static UserDto ToDto(User user) =>
        new(user.Id, user.Email, user.FullName, user.CreatedAt, user.Role.ToString(), user.IsActive, user.LastLoginAt);
}
