namespace FinoraTwin.Domain.Entities;

public class Document
{
    public Guid Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Source { get; set; } = string.Empty;
    public string? Tags { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public ICollection<DocumentChunk> Chunks { get; set; } = new List<DocumentChunk>();
}
