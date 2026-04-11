namespace Domain.Entities;

public class MissionProgress
{
    public Guid Id { get; set; }
    public Guid MissionId { get; set; }
    public Guid UserId { get; set; }
    public Guid CurrentClueId { get; set; }
    public DateTimeOffset StartedAt { get; set; }
    public DateTimeOffset? CompletedAt { get; set; }
    public MissionProgressStatus Status { get; set; }
    public int HintsUsed { get; set; }

    public Mission Mission { get; set; } = null!;
    public User User { get; set; } = null!;
    public Clue CurrentClue { get; set; } = null!;
}
