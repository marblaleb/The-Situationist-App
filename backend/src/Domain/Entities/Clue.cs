using NetTopologySuite.Geometries;

namespace Domain.Entities;

public class Clue
{
    public Guid Id { get; set; }
    public Guid MissionId { get; set; }
    public int Order { get; set; }
    public ClueType Type { get; set; }
    public string Content { get; set; } = string.Empty;
    public string? Hint { get; set; }
    public string AnswerHash { get; set; } = string.Empty;
    public bool IsOptional { get; set; }
    public Point? Location { get; set; }

    public Mission Mission { get; set; } = null!;
}
