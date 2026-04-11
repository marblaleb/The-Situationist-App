namespace Api.Features.Missions;

public record CreateClueRequest(
    int Order,
    string Type,
    string Content,
    string? Hint,
    string Answer,
    bool IsOptional,
    double? Latitude,
    double? Longitude);

public record CreateMissionRequest(
    string Title,
    string Description,
    double Latitude,
    double Longitude,
    int RadiusMeters,
    List<CreateClueRequest> Clues);

public record MissionSummaryResponse(
    Guid Id,
    string Title,
    string Description,
    double Latitude,
    double Longitude,
    int RadiusMeters,
    string Status,
    int ClueCount);

public record ClueResponse(
    Guid Id,
    int Order,
    string Type,
    string Content,
    bool HasHint,
    bool IsOptional,
    double? Latitude,
    double? Longitude);

public record MissionDetailResponse(
    Guid Id,
    string Title,
    string Description,
    double Latitude,
    double Longitude,
    int RadiusMeters,
    string Status,
    List<ClueResponse> Clues);

public record SubmitClueAnswerRequest(string Answer);

public record MissionProgressResponse(
    Guid ProgressId,
    Guid MissionId,
    string Status,
    DateTimeOffset StartedAt,
    DateTimeOffset? CompletedAt,
    int HintsUsed,
    ClueResponse? CurrentClue);
