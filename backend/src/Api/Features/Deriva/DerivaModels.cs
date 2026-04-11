namespace Api.Features.Deriva;

public record StartDerivaRequest(string Type, double Latitude, double Longitude, string Language = "es");

public record DerivaSessionResponse(
    Guid Id,
    string Type,
    DateTimeOffset StartedAt,
    string Status,
    string FirstInstruction);

public record DerivaInstructionResponse(Guid InstructionId, string Content, DateTimeOffset GeneratedAt);

public record NextInstructionRequest(double Latitude, double Longitude, string? Lang);
