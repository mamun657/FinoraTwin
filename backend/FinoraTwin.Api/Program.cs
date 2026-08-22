using System.Text;
using DotNetEnv;
using FinoraTwin.Api.Middleware;
using FinoraTwin.Domain.Abstractions;
using FinoraTwin.Infrastructure.Ai;
using FinoraTwin.Infrastructure.Persistence;
using FinoraTwin.Infrastructure.Repositories;
using FinoraTwin.Infrastructure.Security;
using FinoraTwin.Infrastructure.Services;
using FinoraTwin.Api.Seed;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

Env.Load(Path.Combine(Directory.GetCurrentDirectory(), "..", ".env"));
Env.Load();

var jwtSection = builder.Configuration.GetSection("Jwt");
var jwtSecret = Environment.GetEnvironmentVariable("Jwt__Secret") ?? jwtSection["Secret"] ?? "";
var jwtIssuer = jwtSection["Issuer"] ?? "finora-twin";
var jwtAudience = jwtSection["Audience"] ?? "finora-twin-clients";
var jwtAccessMinutes = int.TryParse(jwtSection["AccessTokenMinutes"], out var m) ? m : 60;
var jwtRefreshDays = int.TryParse(jwtSection["RefreshTokenDays"], out var d) ? d : 30;

if (string.IsNullOrWhiteSpace(jwtSecret) || jwtSecret.Length < 32)
    throw new InvalidOperationException("Jwt:Secret is missing or too short. Set the Jwt__Secret environment variable to a 32+ byte random string.");

var groqSection = builder.Configuration.GetSection("Groq");
var groqSettings = new GroqSettings
{
    ApiKey = Environment.GetEnvironmentVariable("GROQ_API_KEY") ?? groqSection["ApiKey"] ?? "",
    BaseUrl = Environment.GetEnvironmentVariable("GROQ__BaseUrl") ?? groqSection["BaseUrl"] ?? "https://api.groq.com/openai/v1",
    ChatModel = Environment.GetEnvironmentVariable("GROQ__ChatModel") ?? groqSection["ChatModel"] ?? "openai/gpt-oss-20b",
    TimeoutSeconds = int.TryParse(Environment.GetEnvironmentVariable("GROQ__TimeoutSeconds") ?? groqSection["TimeoutSeconds"], out var ts) ? ts : 60
};

if (string.IsNullOrWhiteSpace(groqSettings.ApiKey))
    throw new InvalidOperationException("GROQ_API_KEY is not set. Provide it via the GROQ_API_KEY environment variable.");

var rawDatabaseUrl = Environment.GetEnvironmentVariable("DATABASE_URL");
var rawConnectionDefault = builder.Configuration.GetConnectionString("Default");
var conn = NormalizeConnectionString(rawDatabaseUrl, rawConnectionDefault);
if (string.IsNullOrWhiteSpace(conn))
{
    var seen = (rawDatabaseUrl, rawConnectionDefault) switch
    {
        (null or "", null or "") => "neither DATABASE_URL nor ConnectionStrings:Default was set",
        (null or "", _)          => "DATABASE_URL was empty and ConnectionStrings:Default was empty",
        (_, null or "")          => "DATABASE_URL was set but parsed to an empty connection string",
        _                        => "both DATABASE_URL and ConnectionStrings:Default were empty after normalization"
    };
    throw new InvalidOperationException(
        "PostgreSQL connection is not configured. Set the DATABASE_URL environment variable " +
        "(postgres://USER:PASSWORD@HOST/DB?sslmode=require) on the host (e.g. Render). " +
        $"Detected: {seen}.");
}

var connHostLog = SafeHostForLog(conn);
Console.WriteLine($"[startup] PostgreSQL host resolved to: {connHostLog}");

builder.Services.AddDbContext<AppDbContext>(opt => opt.UseNpgsql(conn));

static string SafeHostForLog(string npsqlConn)
{
    foreach (var part in npsqlConn.Split(';', StringSplitOptions.RemoveEmptyEntries))
    {
        var kv = part.Split('=', 2);
        if (kv.Length == 2 && kv[0].Trim().Equals("Host", StringComparison.OrdinalIgnoreCase))
            return kv[1].Trim();
    }
    return "(unknown)";
}

static string? NormalizeConnectionString(string? urlOrConn, string? connStr)
{
    if (!string.IsNullOrWhiteSpace(urlOrConn))
    {
        if (urlOrConn.Contains("://", StringComparison.Ordinal))
        {
            try
            {
                var uri = new Uri(urlOrConn);
                var sb = new System.Text.StringBuilder();
                sb.Append("Host=").Append(uri.Host);
                if (!uri.IsDefaultPort) sb.Append(";Port=").Append(uri.Port);
                var userInfo = uri.UserInfo.Split(':', 2);
                if (userInfo.Length > 0 && !string.IsNullOrEmpty(userInfo[0])) sb.Append(";Username=").Append(Uri.UnescapeDataString(userInfo[0]));
                if (userInfo.Length > 1) sb.Append(";Password=").Append(Uri.UnescapeDataString(userInfo[1]));
                sb.Append(";Database=").Append(uri.AbsolutePath.TrimStart('/'));
                if (!string.IsNullOrEmpty(uri.Query))
                {
                    var unsupported = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
                    {
                        "channel_binding", "channel-binding"
                    };
                    foreach (var part in uri.Query.TrimStart('?').Split('&', StringSplitOptions.RemoveEmptyEntries))
                    {
                        var kv = part.Split('=', 2);
                        if (kv.Length != 2) continue;
                        var key = Uri.UnescapeDataString(kv[0]);
                        if (unsupported.Contains(key)) continue;
                        sb.Append(';').Append(key).Append('=').Append(Uri.UnescapeDataString(kv[1]));
                    }
                }
                if ((uri.Scheme == "postgres" || uri.Scheme == "postgresql")
                    && sb.ToString().IndexOf("SslMode=", StringComparison.OrdinalIgnoreCase) < 0)
                {
                    sb.Append(";SslMode=Require");
                }
                return sb.ToString();
            }
            catch (UriFormatException)
            {
            }
        }
        return urlOrConn;
    }
    return connStr;
}

builder.Services.AddSingleton<IDateTime, SystemDateTime>();
builder.Services.AddSingleton<IPasswordHasher, PasswordHasher>();
builder.Services.AddSingleton<ITokenService>(_ => new TokenService(new JwtSettings
{
    Secret = jwtSecret,
    Issuer = jwtIssuer,
    Audience = jwtAudience,
    AccessTokenMinutes = jwtAccessMinutes,
    RefreshTokenDays = jwtRefreshDays
}));

builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<IRefreshTokenRepository, RefreshTokenRepository>();
builder.Services.AddScoped<IBusinessRepository, BusinessRepository>();
builder.Services.AddScoped<ITransactionRepository, TransactionRepository>();
builder.Services.AddScoped<ILoanRepository, LoanRepository>();
builder.Services.AddScoped<ISimulationRepository, SimulationRepository>();
builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();

builder.Services.AddScoped<IAuditLogger, AuditLogger>();
builder.Services.AddScoped<IFinancialCalculationService, FinancialCalculationService>();
builder.Services.AddScoped<ICapitalSimulationService, CapitalSimulationService>();
builder.Services.AddScoped<IRiskAssessmentService, RiskAssessmentService>();
builder.Services.AddScoped<IStressTestService, StressTestService>();
builder.Services.AddSingleton(groqSettings);
builder.Services.AddHttpClient<IGroqClient, GroqClient>();

builder.Services.AddScoped<IAuditLogRepository, AuditLogRepository>();
builder.Services.AddHostedService<AdminSeeder>();

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(o =>
    {
        o.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtIssuer,
            ValidAudience = jwtAudience,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSecret)),
            ClockSkew = TimeSpan.FromMinutes(1),
            NameClaimType = System.Security.Claims.ClaimTypes.NameIdentifier,
            RoleClaimType = System.Security.Claims.ClaimTypes.Role
        };
    });
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("Admin", policy => policy.RequireRole("Admin"));
});

builder.Services.AddControllers()
    .AddJsonOptions(o =>
    {
        o.JsonSerializerOptions.PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase;
        o.JsonSerializerOptions.Converters.Add(new System.Text.Json.Serialization.JsonStringEnumConverter());
    });
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "FinoraTwin API", Version = "v1" });
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "JWT Authorization header"
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        [new OpenApiSecurityScheme { Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" } }] = Array.Empty<string>()
    });
});

var app = builder.Build();

app.UseMiddleware<ExceptionHandlingMiddleware>();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();
