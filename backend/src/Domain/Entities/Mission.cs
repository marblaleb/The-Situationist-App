using NetTopologySuite.Geometries;

namespace Domain.Entities;

public class Mission
{
    public Guid Id { get; set; }
    public Guid CreatorId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public Point Location { get; set; } = null!;
    public int RadiusMeters { get; set; }
    public MissionStatus Status { get; set; }
    public DateTimeOffset CreatedAt { get; set; }

    public User Creator { get; set; } = null!;
    public ICollection<Clue> Clues { get; set; } = new List<Clue>();
}
