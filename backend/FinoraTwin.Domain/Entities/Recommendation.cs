namespace FinoraTwin.Domain.Entities;

public class Recommendation
{
    public Guid Id { get; set; }
    public Guid BusinessId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Body { get; set; } = string.Empty;
    public string Severity { get; set; } = "info"; // info | warning | danger | success
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public Business? Business { get; set; }
}
