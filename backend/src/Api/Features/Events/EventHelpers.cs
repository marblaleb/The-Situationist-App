using Domain;
using Domain.Entities;

namespace Api.Features.Events;

internal static class EventHelpers
{
    internal static EventResponse MapToResponse(Event e, int participantCount) => new(
        e.Id, e.Title, e.Description,
        e.ActionType.ToString(), e.InterventionLevel.ToString(),
        e.Location.Y, e.Location.X,
        e.RadiusMeters, e.Visibility.ToString(),
        e.MaxParticipants, e.StartsAt, e.ExpiresAt,
        e.Status.ToString(), participantCount);
}
