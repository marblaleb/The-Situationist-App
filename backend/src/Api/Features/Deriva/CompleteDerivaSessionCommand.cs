using Domain;
using Domain.Entities;
using Infrastructure.Persistence;
using MediatR;
using Microsoft.EntityFrameworkCore;
using System.Text.Json;

namespace Api.Features.Deriva;

public record CompleteDerivaSessionCommand(Guid SessionId, Guid UserId) : IRequest<Unit>;

public class CompleteDerivaSessionCommandHandler(AppDbContext db)
    : IRequestHandler<CompleteDerivaSessionCommand, Unit>
{
    public async Task<Unit> Handle(CompleteDerivaSessionCommand request, CancellationToken ct)
    {
        var session = await db.DerivaSessions
            .FirstOrDefaultAsync(s => s.Id == request.SessionId && s.UserId == request.UserId, ct)
            ?? throw new KeyNotFoundException("Session not found");

        if (session.Status != DerivaStatus.Active)
            throw new InvalidOperationException("Session is not active");

        session.Status = DerivaStatus.Completed;
        session.EndedAt = DateTimeOffset.UtcNow;

        db.ActivityLogs.Add(new ActivityLog
        {
            Id = Guid.NewGuid(),
            UserId = request.UserId,
            Type = ActivityLogType.DerivaCompleted,
            ReferenceId = session.Id,
            OccurredAt = DateTimeOffset.UtcNow,
            Metadata = JsonDocument.Parse($"{{\"derivaType\":\"{session.Type}\"}}")
        });

        await db.SaveChangesAsync(ct);
        return Unit.Value;
    }
}
