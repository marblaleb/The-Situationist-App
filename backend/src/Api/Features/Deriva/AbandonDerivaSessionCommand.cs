using Domain;
using Infrastructure.Persistence;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Api.Features.Deriva;

public record AbandonDerivaSessionCommand(Guid SessionId, Guid UserId) : IRequest<Unit>;

public class AbandonDerivaSessionCommandHandler(AppDbContext db)
    : IRequestHandler<AbandonDerivaSessionCommand, Unit>
{
    public async Task<Unit> Handle(AbandonDerivaSessionCommand request, CancellationToken ct)
    {
        var session = await db.DerivaSessions
            .FirstOrDefaultAsync(s => s.Id == request.SessionId && s.UserId == request.UserId, ct)
            ?? throw new KeyNotFoundException("Session not found");

        if (session.Status != DerivaStatus.Active)
            throw new InvalidOperationException("Session is not active");

        session.Status = DerivaStatus.Abandoned;
        session.EndedAt = DateTimeOffset.UtcNow;

        await db.SaveChangesAsync(ct);
        return Unit.Value;
    }
}
