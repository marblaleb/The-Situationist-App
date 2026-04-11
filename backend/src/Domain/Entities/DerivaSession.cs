namespace Domain.Entities;

public class DerivaSession
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public DerivaType Type { get; set; }
    public DateTimeOffset StartedAt { get; set; }
    public DateTimeOffset? EndedAt { get; set; }
    public DerivaStatus Status { get; set; }

    public User User { get; set; } = null!;
    public ICollection<DerivaInstruction> Instructions { get; set; } = new List<DerivaInstruction>();
}
