using Domain;
using Infrastructure.Persistence;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Api.Features.Missions;

public record GetMissionProgressQuery(Guid MissionId, Guid UserId) : IRequest<MissionProgressResponse?>;

public class GetMissionProgressQueryHandler(AppDbContext db)
    : IRequestHandler<GetMissionProgressQuery, MissionProgressResponse?>
{
    public async Task<MissionProgressResponse?> Handle(GetMissionProgressQuery request, CancellationToken ct)
    {
        var progress = await db.MissionProgresses
            .Include(p => p.CurrentClue)
            .FirstOrDefaultAsync(p =>
                p.MissionId == request.MissionId &&
                p.UserId == request.UserId &&
                p.Status == MissionProgressStatus.InProgress, ct);

        if (progress is null) return null;

        return new MissionProgressResponse(
            progress.Id, progress.MissionId, progress.Status.ToString(),
            progress.StartedAt, progress.CompletedAt, progress.HintsUsed,
            MissionHelpers.MapClue(progress.CurrentClue));
    }
}
