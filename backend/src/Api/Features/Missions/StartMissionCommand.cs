using Domain;
using Domain.Entities;
using Infrastructure.Persistence;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Api.Features.Missions;

public record StartMissionCommand(Guid MissionId, Guid UserId) : IRequest<MissionProgressResponse>;

public class StartMissionCommandHandler(AppDbContext db)
    : IRequestHandler<StartMissionCommand, MissionProgressResponse>
{
    public async Task<MissionProgressResponse> Handle(StartMissionCommand request, CancellationToken ct)
    {
        var mission = await db.Missions
            .Include(m => m.Clues.OrderBy(c => c.Order))
            .FirstOrDefaultAsync(m => m.Id == request.MissionId, ct)
            ?? throw new KeyNotFoundException("Mission not found");

        if (mission.Status != MissionStatus.Active)
            throw new InvalidOperationException("Mission is not active");

        if (mission.CreatorId == request.UserId)
            throw new InvalidOperationException("Creator cannot start their own mission");

        var hasActive = await db.MissionProgresses.AnyAsync(
            p => p.MissionId == request.MissionId && p.UserId == request.UserId && p.Status == MissionProgressStatus.InProgress, ct);
        if (hasActive)
            throw new InvalidOperationException("Already have an active progress for this mission");

        var firstClue = mission.Clues.FirstOrDefault(c => !c.IsOptional)
            ?? mission.Clues.FirstOrDefault()
            ?? throw new InvalidOperationException("Mission has no clues");

        var progress = new MissionProgress
        {
            Id = Guid.NewGuid(),
            MissionId = request.MissionId,
            UserId = request.UserId,
            CurrentClueId = firstClue.Id,
            StartedAt = DateTimeOffset.UtcNow,
            Status = MissionProgressStatus.InProgress,
            HintsUsed = 0
        };

        db.MissionProgresses.Add(progress);
        await db.SaveChangesAsync(ct);

        return new MissionProgressResponse(
            progress.Id, progress.MissionId, progress.Status.ToString(),
            progress.StartedAt, progress.CompletedAt, progress.HintsUsed,
            MissionHelpers.MapClue(firstClue));
    }

}
