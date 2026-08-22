using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using FinoraTwin.Domain.Abstractions;
using FinoraTwin.Domain.Enums;
using Microsoft.IdentityModel.Tokens;

namespace FinoraTwin.Infrastructure.Security;

public class JwtSettings
{
    public string Issuer { get; set; } = "FinoraTwin";
    public string Audience { get; set; } = "FinoraTwin";
    public string Secret { get; set; } = string.Empty;
    public int AccessTokenMinutes { get; set; } = 60;
    public int RefreshTokenDays { get; set; } = 30;
}

public class TokenService : ITokenService
{
    private readonly JwtSettings _settings;
    public TokenService(JwtSettings settings) => _settings = settings;

    public (string Token, DateTime ExpiresAt) CreateAccessToken(Guid userId, string email, string fullName, UserRole role)
    {
        var keyBytes = Encoding.UTF8.GetBytes(_settings.Secret);
        var creds = new SigningCredentials(new SymmetricSecurityKey(keyBytes), SecurityAlgorithms.HmacSha256);
        var expires = DateTime.UtcNow.AddMinutes(_settings.AccessTokenMinutes);
        var claims = new List<Claim>
        {
            new(JwtRegisteredClaimNames.Sub, userId.ToString()),
            new(JwtRegisteredClaimNames.Email, email),
            new(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
            new(ClaimTypes.NameIdentifier, userId.ToString()),
            new(ClaimTypes.Email, email),
            new(ClaimTypes.Role, role.ToString()),
            new("name", fullName),
            new("role", role.ToString())
        };
        var token = new JwtSecurityToken(
            issuer: _settings.Issuer,
            audience: _settings.Audience,
            claims: claims,
            notBefore: DateTime.UtcNow,
            expires: expires,
            signingCredentials: creds);
        return (new JwtSecurityTokenHandler().WriteToken(token), expires);
    }

    public string GenerateRefreshToken()
    {
        var bytes = new byte[64];
        RandomNumberGenerator.Fill(bytes);
        return Convert.ToBase64String(bytes);
    }

    public DateTime GetRefreshTokenExpiry() => DateTime.UtcNow.AddDays(30);
}
