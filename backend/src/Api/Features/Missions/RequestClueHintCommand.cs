using Domain;
using Infrastructure.Persistence;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Api.Features.Missions;

public record RequestClueHintCommand(Guid MissionId, Guid ClueId, Guid UserId) : IRequest<string?>;

public class RequestClueHintCommandHandler(AppDbContext db)
    : IRequestHandler<RequestClueHintCommand, string?>
{
    public async Task<string?> Handle(RequestClueHintCommand request, CancellationToken ct)
    {
        var progress = await db.MissionProgresses
            .FirstOrDefaultAsync(p =>
                p.MissionId == request.MissionId &&
                p.UserId == request.UserId &&
                p.Status == MissionProgressStatus.InProgress, ct)
            ?? throw new KeyNotFoundException("No active progress for this mission");

        if (progress.CurrentClueId != request.ClueId)
            throw new InvalidOperationException("This is not the current clue");

        var clue = await db.Clues.FindAsync(new object[] { request.ClueId }, ct)
            ?? throw new KeyNotFoundException("Clue not found");

        if (clue.Hint is not null)
        {
            progress.HintsUsed++;
            await db.SaveChangesAsync(ct);
        }

        return clue.Hint;
    }
}
