namespace Domain.Entities;

public class Participation
{
    public Guid Id { get; set; }
    public Guid EventId { get; set; }
    public Guid UserId { get; set; }
    public ParticipationRole Role { get; set; }
    public DateTimeOffset JoinedAt { get; set; }

    public Event Event { get; set; } = null!;
    public User User { get; set; } = null!;
}
