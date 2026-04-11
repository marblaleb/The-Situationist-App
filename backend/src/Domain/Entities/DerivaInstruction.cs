using System.Text.Json;

namespace Domain.Entities;

public class DerivaInstruction
{
    public Guid Id { get; set; }
    public Guid SessionId { get; set; }
    public string Content { get; set; } = string.Empty;
    public DateTimeOffset GeneratedAt { get; set; }
    public JsonDocument ContextSnapshot { get; set; } = JsonDocument.Parse("{}");

    public DerivaSession Session { get; set; } = null!;
}
