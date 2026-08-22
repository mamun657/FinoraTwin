using System.Text.Json;

namespace FinoraTwin.Api.Middleware;

public class ExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionHandlingMiddleware> _logger;
    private readonly IHostEnvironment _env;

    public ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger, IHostEnvironment env)
    {
        _next = next;
        _logger = logger;
        _env = env;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (UnauthorizedAccessException ex)
        {
            _logger.LogWarning(ex, "Unauthorized");
            await Write(context, StatusCodes.Status401Unauthorized, "unauthorized", ex.Message);
        }
        catch (KeyNotFoundException ex)
        {
            _logger.LogWarning(ex, "Not found");
            await Write(context, StatusCodes.Status404NotFound, "not_found", ex.Message);
        }
        catch (ArgumentException ex)
        {
            _logger.LogWarning(ex, "Bad request");
            await Write(context, StatusCodes.Status400BadRequest, "bad_request", ex.Message);
        }
        catch (InvalidOperationException ex)
        {
            _logger.LogWarning(ex, "Conflict");
            await Write(context, StatusCodes.Status409Conflict, "conflict", ex.Message);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unhandled exception");
            await Write(context, StatusCodes.Status500InternalServerError, "server_error",
                _env.IsDevelopment() ? ex.Message : "An unexpected error occurred.");
        }
    }

    private static async Task Write(HttpContext context, int status, string code, string message)
    {
        if (context.Response.HasStarted) return;
        context.Response.Clear();
        context.Response.StatusCode = status;
        context.Response.ContentType = "application/json";
        var payload = JsonSerializer.Serialize(new { error = new { code, message } });
        await context.Response.WriteAsync(payload);
    }
}
