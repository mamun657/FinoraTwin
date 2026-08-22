using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using FinoraTwin.Domain.Abstractions;
using Microsoft.Extensions.Logging;

namespace FinoraTwin.Infrastructure.Ai;

public class GroqSettings
{
    public string ApiKey { get; set; } = string.Empty;
    public string BaseUrl { get; set; } = "https://api.groq.com/openai/v1";
    public string ChatModel { get; set; } = "openai/gpt-oss-20b";
    public int TimeoutSeconds { get; set; } = 60;
}

public class BusinessToolDispatcher
{
    private readonly Guid _businessId;
    private readonly IFinancialCalculationService _financial;
    private readonly ICapitalSimulationService _simulation;
    private readonly IStressTestService _stress;
    private readonly ITransactionRepository _transactions;
    private readonly ILoanRepository _loans;

    public BusinessToolDispatcher(
        Guid businessId,
        IFinancialCalculationService financial,
        ICapitalSimulationService simulation,
        IStressTestService stress,
        ITransactionRepository transactions,
        ILoanRepository loans)
    {
        _businessId = businessId;
        _financial = financial;
        _simulation = simulation;
        _stress = stress;
        _transactions = transactions;
        _loans = loans;
    }

    public IReadOnlyList<GroqToolDefinition> GetTools() => new List<GroqToolDefinition>
    {
        new("GetFinancialSummary", "Returns monthly average income, expenses, net cash flow, and standard deviations over the last 3 months.", new Dictionary<string, object>
        {
            ["type"] = "object",
            ["properties"] = new Dictionary<string, object>()
        }),
        new("GetFinancialHealth", "Returns the calculated financial health score and sub-scores for the business.", new Dictionary<string, object>
        {
            ["type"] = "object",
            ["properties"] = new Dictionary<string, object>()
        }),
        new("GetTopExpenseCategories", "Returns the top expense categories for the last 90 days.", new Dictionary<string, object>
        {
            ["type"] = "object",
            ["properties"] = new Dictionary<string, object>
            {
                ["top"] = new Dictionary<string, object> { ["type"] = "integer", ["default"] = 5 }
            }
        }),
        new("GetOutstandingDebt", "Returns the total outstanding debt across all loans for the business.", new Dictionary<string, object>
        {
            ["type"] = "object",
            ["properties"] = new Dictionary<string, object>()
        }),
        new("SimulateFinancing", "Simulates a financing request and returns the engine-computed result. Do not compute financing yourself.", new Dictionary<string, object>
        {
            ["type"] = "object",
            ["properties"] = new Dictionary<string, object>
            {
                ["requestedAmount"] = new Dictionary<string, object> { ["type"] = "number" },
                ["termMonths"] = new Dictionary<string, object> { ["type"] = "integer" },
                ["annualInterestRate"] = new Dictionary<string, object> { ["type"] = "number" },
                ["salesChangePercent"] = new Dictionary<string, object> { ["type"] = "number", ["default"] = 0 }
            },
            ["required"] = new[] { "requestedAmount", "termMonths" }
        }),
        new("RunStressTest", "Runs a sales/expense stress test and returns scenario results.", new Dictionary<string, object>
        {
            ["type"] = "object",
            ["properties"] = new Dictionary<string, object>
            {
                ["salesChangePercent"] = new Dictionary<string, object> { ["type"] = "number" },
                ["expenseChangePercent"] = new Dictionary<string, object> { ["type"] = "number" }
            }
        })
    };

    public async Task<string> ExecuteAsync(string toolName, JsonElement arguments, CancellationToken ct)
    {
        switch (toolName)
        {
            case "GetFinancialSummary":
            {
                var now = DateTime.UtcNow;
                var from = DateTime.SpecifyKind(new DateTime(now.Year, now.Month, 1).AddMonths(-2), DateTimeKind.Utc);
                var to = DateTime.SpecifyKind(new DateTime(now.Year, now.Month, 1).AddMonths(1).AddTicks(-1), DateTimeKind.Utc);
                var m = await _financial.CalculateCashFlowAsync(_businessId, from, to, ct);
                return JsonSerializer.Serialize(new
                {
                    avgMonthlyIncome = m.AvgMonthlyIncome,
                    avgMonthlyExpenses = m.AvgMonthlyExpenses,
                    netCashFlow = m.NetCashFlow,
                    incomeStdDev = m.IncomeStdDev,
                    expenseStdDev = m.ExpenseStdDev
                });
            }
            case "GetFinancialHealth":
            {
                var h = await _financial.CalculateHealthAsync(_businessId, ct);
                return JsonSerializer.Serialize(new
                {
                    overallScore = h.OverallScore,
                    status = h.Status.ToString(),
                    cashFlowStability = h.CashFlowStabilityScore,
                    expenseControl = h.ExpenseControlScore,
                    debtBurden = h.DebtBurdenScore,
                    cashBuffer = h.CashBufferScore,
                    revenueStability = h.RevenueStabilityScore,
                    cashBufferWeeks = h.CashBufferWeeks
                });
            }
            case "GetTopExpenseCategories":
            {
                var top = arguments.TryGetProperty("top", out var t) && t.ValueKind == JsonValueKind.Number ? t.GetInt32() : 5;
                var now = DateTime.UtcNow;
                var from = now.AddDays(-90);
                var cats = await _transactions.TopExpenseCategoriesAsync(_businessId, from, now, top, ct);
                return JsonSerializer.Serialize(cats.Select(c => new { category = c.Category, total = c.Total }));
            }
            case "GetOutstandingDebt":
            {
                var debt = await _loans.TotalOutstandingDebtAsync(_businessId, ct);
                return JsonSerializer.Serialize(new { outstandingDebt = debt });
            }
            case "SimulateFinancing":
            {
                var amount = arguments.GetProperty("requestedAmount").GetDecimal();
                var term = arguments.TryGetProperty("termMonths", out var tm) ? tm.GetInt32() : 12;
                var rate = arguments.TryGetProperty("annualInterestRate", out var r) ? r.GetDecimal() : 12m;
                var sales = arguments.TryGetProperty("salesChangePercent", out var s) ? s.GetDecimal() : 0m;
                var result = await _simulation.SimulateAsync(_businessId,
                    new Domain.Models.CapitalSimulationInput(amount, "AI-Initiated", term, rate, sales), ct);
                return JsonSerializer.Serialize(new
                {
                    projectedRevenue = result.ProjectedRevenue,
                    projectedExpenses = result.ProjectedExpenses,
                    projectedCashFlow = result.ProjectedCashFlow,
                    monthlyRepaymentBurden = result.MonthlyRepaymentBurden,
                    projectedCashBuffer = result.ProjectedCashBuffer,
                    recommendedMin = result.RecommendedMinAmount,
                    recommendedMax = result.RecommendedMaxAmount,
                    risk = result.RiskLevel.ToString(),
                    reasons = result.Reasons
                });
            }
            case "RunStressTest":
            {
                var sales = arguments.TryGetProperty("salesChangePercent", out var s) ? s.GetDecimal() : 0m;
                var exp = arguments.TryGetProperty("expenseChangePercent", out var e) ? e.GetDecimal() : 0m;
                var result = await _stress.RunAsync(_businessId, new Domain.Models.StressTestInput(sales, exp), ct);
                return JsonSerializer.Serialize(new
                {
                    adjustedRevenue = result.AdjustedRevenue,
                    adjustedExpenses = result.AdjustedExpenses,
                    adjustedNetCashFlow = result.AdjustedNetCashFlow,
                    adjustedCashBufferWeeks = result.AdjustedCashBufferWeeks,
                    risk = result.RiskLevel.ToString(),
                    notes = result.Notes
                });
            }
            default:
                return JsonSerializer.Serialize(new { error = "Unknown tool" });
        }
    }
}

public class GroqClient : IGroqClient
{
    private readonly HttpClient _http;
    private readonly GroqSettings _settings;
    private readonly ILogger<GroqClient> _logger;

    public GroqClient(HttpClient http, GroqSettings settings, ILogger<GroqClient> logger)
    {
        _http = http;
        _settings = settings;
        _logger = logger;
    }

    public Task<string> ChatAsync(IReadOnlyList<GroqMessage> messages, IReadOnlyList<GroqToolDefinition> tools, CancellationToken ct = default)
        => ChatWithDispatcherAsync(messages, tools, null!, ct);

    public async Task<string> ChatWithDispatcherAsync(
        IReadOnlyList<GroqMessage> messages,
        IReadOnlyList<GroqToolDefinition> tools,
        object dispatcherObj,
        CancellationToken ct = default)
    {
        var dispatcher = dispatcherObj as BusinessToolDispatcher;
        if (string.IsNullOrWhiteSpace(_settings.ApiKey))
            throw new InvalidOperationException("Groq API key is not configured.");

        _http.BaseAddress = new Uri(_settings.BaseUrl);
        if (_http.DefaultRequestHeaders.Authorization is null ||
            _http.DefaultRequestHeaders.Authorization.Parameter != _settings.ApiKey)
        {
            _http.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", _settings.ApiKey);
        }
        _http.Timeout = TimeSpan.FromSeconds(_settings.TimeoutSeconds);

        var body = new
        {
            model = _settings.ChatModel,
            messages = messages.Select(m => new { role = m.Role, content = m.Content }).ToList(),
            tools = tools.Select(t => new
            {
                type = "function",
                function = new { name = t.Name, description = t.Description, parameters = t.Parameters }
            }).ToList(),
            tool_choice = "auto",
            temperature = 0.2
        };

        var endpoint = new Uri(_settings.BaseUrl.TrimEnd('/') + "/chat/completions");
        using var resp = await _http.PostAsJsonAsync(endpoint, body, ct);
        var raw = await resp.Content.ReadAsStringAsync(ct);
        if (!resp.IsSuccessStatusCode)
        {
            _logger.LogWarning("Groq returned non-success status.");
            throw new HttpRequestException("AI provider returned an error.");
        }

        using var doc = JsonDocument.Parse(raw);
        var root = doc.RootElement;
        var firstChoice = root.GetProperty("choices")[0];
        var message = firstChoice.GetProperty("message");

        if (dispatcher is not null && message.TryGetProperty("tool_calls", out var toolCalls) && toolCalls.GetArrayLength() > 0)
        {
            var toolMessages = new List<object>();
            foreach (var call in toolCalls.EnumerateArray())
            {
                var fn = call.GetProperty("function");
                var name = fn.GetProperty("name").GetString() ?? "";
                var args = fn.GetProperty("arguments").GetString() ?? "{}";
                JsonElement argsJson;
                try { argsJson = JsonDocument.Parse(args).RootElement.Clone(); }
                catch { argsJson = JsonDocument.Parse("{}").RootElement.Clone(); }

                var result = await dispatcher.ExecuteAsync(name, argsJson, ct);
                toolMessages.Add(new { role = "tool", tool_call_id = call.GetProperty("id").GetString(), content = result });
            }
            var followupMessages = new List<object>(messages.Select(m => new { role = m.Role, content = m.Content }))
            {
                new { role = "assistant", content = (string?)null, tool_calls = toolCalls }
            };
            followupMessages.AddRange(toolMessages);

            var follow = new { model = _settings.ChatModel, messages = followupMessages, temperature = 0.2 };
            var endpoint2 = new Uri(_settings.BaseUrl.TrimEnd('/') + "/chat/completions");
            using var resp2 = await _http.PostAsJsonAsync(endpoint2, follow, ct);
            var raw2 = await resp2.Content.ReadAsStringAsync(ct);
            if (!resp2.IsSuccessStatusCode) throw new HttpRequestException("AI provider follow-up failed.");
            using var doc2 = JsonDocument.Parse(raw2);
            return doc2.RootElement.GetProperty("choices")[0].GetProperty("message").GetProperty("content").GetString() ?? "";
        }

        return message.TryGetProperty("content", out var content) ? content.GetString() ?? "" : "";
    }
}
