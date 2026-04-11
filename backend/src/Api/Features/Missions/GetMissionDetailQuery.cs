using Infrastructure.Persistence;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Api.Features.Missions;

public record GetMissionDetailQuery(Guid MissionId) : IRequest<MissionDetailResponse?>;

public class GetMissionDetailQueryHandler(AppDbContext db)
    : IRequestHandler<GetMissionDetailQuery, MissionDetailResponse?>
{
    public async Task<MissionDetailResponse?> Handle(GetMissionDetailQuery request, CancellationToken ct)
    {
        var mission = await db.Missions
            .Include(m => m.Clues.OrderBy(c => c.Order))
            .FirstOrDefaultAsync(m => m.Id == request.MissionId, ct);

        if (mission is null) return null;

        return new MissionDetailResponse(
            mission.Id, mission.Title, mission.Description,
            mission.Location.Y, mission.Location.X,
            mission.RadiusMeters, mission.Status.ToString(),
            mission.Clues.Select(MissionHelpers.MapClue).ToList());
    }
}
