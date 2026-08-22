using FinoraTwin.Domain.Abstractions;
using FinoraTwin.Domain.Entities;
using FinoraTwin.Domain.Enums;
using FinoraTwin.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace FinoraTwin.Api.Seed;

public class AdminSeeder : IHostedService
{
    private const string SeedEmail = "admin@gmail.com";
    private const string SeedPassword = "MANVSRAw12@";
    private const string SeedFullName = "FinoraTwin Administrator";

    private readonly IServiceProvider _services;
    private readonly ILogger<AdminSeeder> _logger;

    public AdminSeeder(IServiceProvider services, ILogger<AdminSeeder> logger)
    {
        _services = services;
        _logger = logger;
    }

    public async Task StartAsync(CancellationToken cancellationToken)
    {
        try
        {
            using var scope = _services.CreateScope();
            var provider = scope.ServiceProvider;
            var db = provider.GetRequiredService<AppDbContext>();
            var users = provider.GetRequiredService<IUserRepository>();
            var hasher = provider.GetRequiredService<IPasswordHasher>();
            var clock = provider.GetRequiredService<IDateTime>();
            var uow = provider.GetRequiredService<IUnitOfWork>();

            var email = SeedEmail.Trim().ToLowerInvariant();
            var existing = await users.GetByEmailAsync(email, cancellationToken);
            if (existing != null)
            {
                if (existing.Role != UserRole.Admin)
                {
                    existing.Role = UserRole.Admin;
                    existing.IsActive = true;
                    existing.UpdatedAt = clock.UtcNow;
                    await uow.SaveChangesAsync(cancellationToken);
                    _logger.LogInformation("Promoted existing user {Email} to Admin role.", SeedEmail);
                }
                else
                {
                    _logger.LogInformation("Admin account already seeded.");
                }
                return;
            }

            var admin = new User
            {
                Id = Guid.NewGuid(),
                Email = email,
                FullName = SeedFullName,
                PasswordHash = hasher.Hash(SeedPassword),
                Role = UserRole.Admin,
                IsActive = true,
                CreatedAt = clock.UtcNow,
                UpdatedAt = clock.UtcNow
            };
            await users.AddAsync(admin, cancellationToken);
            await uow.SaveChangesAsync(cancellationToken);
            _logger.LogInformation("Seeded admin account {Email} with role Admin.", SeedEmail);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Admin seeding failed; the application will continue without a seeded admin.");
        }
    }

    public Task StopAsync(CancellationToken cancellationToken) => Task.CompletedTask;
}