using Domain;
using Domain.Entities;
using Infrastructure.Persistence;
using MediatR;
using Microsoft.EntityFrameworkCore;
using System.Text.Json;

namespace Api.Features.Missions;

public record SubmitClueAnswerCommand(Guid MissionId, Guid ClueId, Guid UserId, string Answer)
    : IRequest<SubmitClueAnswerResult>;

public record SubmitClueAnswerResult(bool Correct, bool MissionCompleted, ClueResponse? NextClue);

public class SubmitClueAnswerCommandHandler(AppDbContext db)
    : IRequestHandler<SubmitClueAnswerCommand, SubmitClueAnswerResult>
{
    public async Task<SubmitClueAnswerResult> Handle(SubmitClueAnswerCommand request, CancellationToken ct)
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

        var isCorrect = BCrypt.Net.BCrypt.Verify(request.Answer.Trim().ToLowerInvariant(), clue.AnswerHash);
        if (!isCorrect)
            return new SubmitClueAnswerResult(false, false, null);

        // Find next required clue
        var allClues = await db.Clues
            .Where(c => c.MissionId == request.MissionId)
            .OrderBy(c => c.Order)
            .ToListAsync(ct);

        var nextClue = allClues
            .Where(c => !c.IsOptional && c.Order > clue.Order)
            .MinBy(c => c.Order);

        if (nextClue is null)
        {
            // Mission complete
            progress.Status = MissionProgressStatus.Completed;
            progress.CompletedAt = DateTimeOffset.UtcNow;

            db.ActivityLogs.Add(new ActivityLog
            {
                Id = Guid.NewGuid(),
                UserId = request.UserId,
                Type = ActivityLogType.MissionCompleted,
                ReferenceId = request.MissionId,
                OccurredAt = DateTimeOffset.UtcNow,
                Metadata = JsonDocument.Parse($"{{\"hintsUsed\":{progress.HintsUsed}}}")
            });

            await db.SaveChangesAsync(ct);
            return new SubmitClueAnswerResult(true, true, null);
        }

        progress.CurrentClueId = nextClue.Id;
        await db.SaveChangesAsync(ct);

        return new SubmitClueAnswerResult(true, false, MissionHelpers.MapClue(nextClue));
    }
}
