using Domain;
using Infrastructure.Persistence;
using MediatR;
using Microsoft.EntityFrameworkCore;
using NetTopologySuite.Geometries;

namespace Api.Features.Missions;

public record GetNearbyMissionsQuery(double Latitude, double Longitude, int RadiusMeters) : IRequest<List<MissionSummaryResponse>>;

public class GetNearbyMissionsQueryHandler(AppDbContext db)
    : IRequestHandler<GetNearbyMissionsQuery, List<MissionSummaryResponse>>
{
    private static readonly GeometryFactory GeoFactory =
        NetTopologySuite.NtsGeometryServices.Instance.CreateGeometryFactory(4326);

    public async Task<List<MissionSummaryResponse>> Handle(GetNearbyMissionsQuery request, CancellationToken ct)
    {
        var center = GeoFactory.CreatePoint(new Coordinate(request.Longitude, request.Latitude));
        center.SRID = 4326;

        var missions = await db.Missions
            .Include(m => m.Clues)
            .Where(m => m.Status == MissionStatus.Active && m.Location.IsWithinDistance(center, request.RadiusMeters))
            .ToListAsync(ct);

        return missions.Select(m => new MissionSummaryResponse(
            m.Id, m.Title, m.Description,
            m.Location.Y, m.Location.X,
            m.RadiusMeters, m.Status.ToString(), m.Clues.Count))
            .ToList();
    }
}
