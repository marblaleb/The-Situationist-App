using Domain;
using Infrastructure.Persistence;
using MediatR;
using Microsoft.EntityFrameworkCore;
using NetTopologySuite.Geometries;

namespace Api.Features.Events;

public record GetNearbyEventsQuery(double Latitude, double Longitude, int RadiusMeters, Guid UserId) : IRequest<List<EventResponse>>;

public class GetNearbyEventsQueryHandler(AppDbContext db) : IRequestHandler<GetNearbyEventsQuery, List<EventResponse>>
{
    private static readonly GeometryFactory GeoFactory =
        NetTopologySuite.NtsGeometryServices.Instance.CreateGeometryFactory(4326);

    public async Task<List<EventResponse>> Handle(GetNearbyEventsQuery request, CancellationToken ct)
    {
        var center = GeoFactory.CreatePoint(new Coordinate(request.Longitude, request.Latitude));
        center.SRID = 4326;

        var events = await db.Events
            .Include(e => e.Participations)
            .Where(e =>
                e.Status == EventStatus.Active &&
                e.Location.IsWithinDistance(center, request.RadiusMeters) &&
                (e.Visibility == EventVisibility.Public || e.Visibility == EventVisibility.ByProximity))
            .ToListAsync(ct);

        return events
            .Select(e => EventHelpers.MapToResponse(
                e,
                e.Participations.Count(p => p.Role == ParticipationRole.Participante),
                isParticipant: e.Participations.Any(p => p.UserId == request.UserId)))
            .ToList();
    }
}
