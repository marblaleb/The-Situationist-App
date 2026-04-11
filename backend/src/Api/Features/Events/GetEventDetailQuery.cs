using Domain;
using Infrastructure.Persistence;
using MediatR;
using Microsoft.EntityFrameworkCore;
using NetTopologySuite.Geometries;

namespace Api.Features.Events;

public record GetEventDetailQuery(
    Guid EventId,
    Guid UserId,
    double? UserLatitude,
    double? UserLongitude) : IRequest<EventResponse?>;

public class GetEventDetailQueryHandler(AppDbContext db) : IRequestHandler<GetEventDetailQuery, EventResponse?>
{
    public async Task<EventResponse?> Handle(GetEventDetailQuery request, CancellationToken ct)
    {
        var evt = await db.Events
            .Include(e => e.Participations)
            .FirstOrDefaultAsync(e => e.Id == request.EventId, ct);

        if (evt is null) return null;

        if (evt.Visibility == EventVisibility.HiddenUntilDiscovery)
        {
            if (!request.UserLatitude.HasValue || !request.UserLongitude.HasValue)
                return null;

            var userPoint = new Point(request.UserLongitude.Value, request.UserLatitude.Value) { SRID = 4326 };
            // IsWithinDistance uses degrees; for SRID 4326 we compare using radius as degrees (~111320m per degree)
            var radiusDegrees = evt.RadiusMeters / 111320.0;
            if (!evt.Location.IsWithinDistance(userPoint, radiusDegrees))
                return null;
        }

        return EventHelpers.MapToResponse(
            evt,
            evt.Participations.Count(p => p.Role == ParticipationRole.Participante));
    }
}
