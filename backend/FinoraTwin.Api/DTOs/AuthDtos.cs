namespace FinoraTwin.Api.DTOs;

public record RegisterRequest(string Email, string Password, string FullName, string BusinessName);
public record LoginRequest(string Email, string Password);
public record RefreshRequest(string RefreshToken);
public record ForgotPasswordRequest(string Email);
public record ForgotPasswordResponse(string Email, bool Accepted, string Message);

public record AuthResponse(
    string AccessToken,
    string RefreshToken,
    DateTime AccessTokenExpiresAt,
    UserDto User);

public record UserDto(
    Guid Id,
    string Email,
    string FullName,
    DateTime CreatedAt,
    string Role,
    bool IsActive,
    DateTime? LastLoginAt);
