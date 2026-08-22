namespace FinoraTwin.Domain.Entities;

public class DocumentChunk
{
    public Guid Id { get; set; }
    public Guid DocumentId { get; set; }
    public int ChunkIndex { get; set; }
    public string Content { get; set; } = string.Empty;
    public float[]? Embedding { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public Document? Document { get; set; }
}
