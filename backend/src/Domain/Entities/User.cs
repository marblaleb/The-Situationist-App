namespace Domain.Entities;

public class User
{
    public Guid Id { get; set; }
    public string ExternalId { get; set; } = string.Empty;
    public Provider Provider { get; set; }
    public string Email { get; set; } = string.Empty;
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset LastSeenAt { get; set; }
}
