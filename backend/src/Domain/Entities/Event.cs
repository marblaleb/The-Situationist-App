using NetTopologySuite.Geometries;

namespace Domain.Entities;

public class Event
{
    public Guid Id { get; set; }
    public Guid CreatorId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public ActionType ActionType { get; set; }
    public InterventionLevel InterventionLevel { get; set; }
    public Point Location { get; set; } = null!;
    public int RadiusMeters { get; set; }
    public EventVisibility Visibility { get; set; }
    public int? MaxParticipants { get; set; }
    public DateTimeOffset StartsAt { get; set; }
    public DateTimeOffset ExpiresAt { get; set; }
    public EventStatus Status { get; set; }
    public DateTimeOffset CreatedAt { get; set; }

    public User Creator { get; set; } = null!;
    public ICollection<Participation> Participations { get; set; } = new List<Participation>();
}
