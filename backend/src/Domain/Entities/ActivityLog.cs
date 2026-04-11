using System.Text.Json;

namespace Domain.Entities;

public class ActivityLog
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public ActivityLogType Type { get; set; }
    public Guid ReferenceId { get; set; }
    public DateTimeOffset OccurredAt { get; set; }
    public JsonDocument Metadata { get; set; } = JsonDocument.Parse("{}");

    public User User { get; set; } = null!;
}
