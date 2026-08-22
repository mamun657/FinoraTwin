namespace FinoraTwin.Api.DTOs;

public record ChatMessage(string Role, string Content);

public record ChatRequest(IReadOnlyList<ChatMessage> Messages);

public record ChatResponse(string Message, DateTime CreatedAt);
