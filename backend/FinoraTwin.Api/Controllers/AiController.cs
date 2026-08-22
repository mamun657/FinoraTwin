using System.Security.Claims;
using FinoraTwin.Api.DTOs;
using FinoraTwin.Domain.Abstractions;
using FinoraTwin.Infrastructure.Ai;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FinoraTwin.Api.Controllers;

[ApiController]
[Authorize]
[Route("api/v1/ai")]
public class AiController : ControllerBase
{
    private readonly IBusinessRepository _businesses;
    private readonly IGroqClient _groq;
    private readonly IFinancialCalculationService _financial;
    private readonly ICapitalSimulationService _simulation;
    private readonly IStressTestService _stress;
    private readonly ITransactionRepository _transactions;
    private readonly ILoanRepository _loans;
    private readonly IDateTime _clock;
    private readonly ILogger<AiController> _logger;

    public AiController(
        IBusinessRepository businesses,
        IGroqClient groq,
        IFinancialCalculationService financial,
        ICapitalSimulationService simulation,
        IStressTestService stress,
        ITransactionRepository transactions,
        ILoanRepository loans,
        IDateTime clock,
        ILogger<AiController> logger)
    {
        _businesses = businesses;
        _groq = groq;
        _financial = financial;
        _simulation = simulation;
        _stress = stress;
        _transactions = transactions;
        _loans = loans;
        _clock = clock;
        _logger = logger;
    }

    [HttpPost("chat")]
    public async Task<ActionResult<ChatResponse>> Chat([FromBody] ChatRequest req, CancellationToken ct)
    {
        if (req.Messages == null || req.Messages.Count == 0)
            throw new ArgumentException("Messages must not be empty.");

        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? throw new UnauthorizedAccessException();
        var business = await _businesses.GetByUserIdAsync(Guid.Parse(userId), ct)
            ?? throw new KeyNotFoundException("Business not found.");

        var dispatcher = new BusinessToolDispatcher(
            business.Id, _financial, _simulation, _stress, _transactions, _loans);

        var pre = await _financial.CalculateHealthAsync(business.Id, ct);
        var system = new GroqMessage("system",
            $"You are FinoraTwin, an AI financial copilot for small business owners. " +
            $"Always base answers on the business's actual data via the provided tools. " +
            $"Be concise, practical, and avoid speculation. Never fabricate financial figures. " +
            $"Current business context: name='{business.Name}', type={business.Type}, currency={business.Currency}, " +
            $"currentCashBuffer={business.CurrentCashBuffer}, monthlyOpEx={business.MonthlyOpEx}, " +
            $"overallHealthScore={pre.OverallScore}, status={pre.Status}.");

        var recent = req.Messages.TakeLast(20)
            .Where(m => m.Role == "user" || m.Role == "assistant")
            .Select(m => new GroqMessage(m.Role, m.Content))
            .ToList();

        try
        {
            var messages = new List<GroqMessage> { system };
            messages.AddRange(recent);
            var reply = await _groq.ChatWithDispatcherAsync(messages, dispatcher.GetTools(), dispatcher, ct);
            return new ChatResponse(reply, _clock.UtcNow);
        }
        catch (HttpRequestException ex)
        {
            _logger.LogError(ex, "AI provider failure");
            throw new InvalidOperationException("AI service is currently unavailable. Please try again.");
        }
    }
}
