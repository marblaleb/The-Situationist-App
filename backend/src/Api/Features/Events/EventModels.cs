namespace Api.Features.Events;

public record CreateEventRequest(
    string Title,
    string Description,
    string ActionType,
    string InterventionLevel,
    double Latitude,
    double Longitude,
    int RadiusMeters,
    string Visibility,
    int? MaxParticipants,
    DateTimeOffset StartsAt,
    int DurationMinutes);

public record EventResponse(
    Guid Id,
    Guid CreatorId,
    string Title,
    string Description,
    string ActionType,
    string InterventionLevel,
    double CentroidLatitude,
    double CentroidLongitude,
    int RadiusMeters,
    string Visibility,
    int? MaxParticipants,
    DateTimeOffset StartsAt,
    DateTimeOffset ExpiresAt,
    string Status,
    int ParticipantCount);

public record GenerateEventRequest(string ActionType, string InterventionLevel, double? Latitude, double? Longitude);

public record ParticipateRequest(string Role);
