using Domain;
using Domain.Entities;
using FluentValidation;
using Infrastructure.Persistence;
using Infrastructure.SignalR;
using MediatR;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using NGeoHash;
using System.Text.Json;

namespace Api.Features.Events;

public record ParticipateInEventCommand(Guid EventId, Guid UserId, string Role) : IRequest<Unit>;

public class ParticipateInEventCommandValidator : AbstractValidator<ParticipateInEventCommand>
{
    public ParticipateInEventCommandValidator()
    {
        RuleFor(x => x.Role)
            .Must(r => r == "Participante" || r == "Observador")
            .WithMessage("Role must be Participante or Observador");
    }
}

public class ParticipateInEventCommandHandler(
    AppDbContext db,
    IHubContext<EventHub> hub) : IRequestHandler<ParticipateInEventCommand, Unit>
{
    public async Task<Unit> Handle(ParticipateInEventCommand request, CancellationToken ct)
    {
        var evt = await db.Events
            .Include(e => e.Participations)
            .FirstOrDefaultAsync(e => e.Id == request.EventId, ct)
            ?? throw new KeyNotFoundException("Event not found");

        if (evt.Status != EventStatus.Active)
            throw new InvalidOperationException("Event is not active");

        var role = Enum.Parse<ParticipationRole>(request.Role);

        if (role == ParticipationRole.Participante && evt.CreatorId == request.UserId)
            throw new InvalidOperationException("Creator cannot participate in their own event");

        if (evt.Participations.Any(p => p.UserId == request.UserId))
            throw new InvalidOperationException("Already participating in this event");

        var participantCount = evt.Participations.Count(p => p.Role == ParticipationRole.Participante);
        if (role == ParticipationRole.Participante && evt.MaxParticipants.HasValue && participantCount >= evt.MaxParticipants.Value)
            throw new InvalidOperationException("Event is full");

        db.Participations.Add(new Participation
        {
            Id = Guid.NewGuid(),
            EventId = request.EventId,
            UserId = request.UserId,
            Role = role,
            JoinedAt = DateTimeOffset.UtcNow
        });

        db.ActivityLogs.Add(new ActivityLog
        {
            Id = Guid.NewGuid(),
            UserId = request.UserId,
            Type = ActivityLogType.EventParticipation,
            ReferenceId = request.EventId,
            OccurredAt = DateTimeOffset.UtcNow,
            Metadata = JsonDocument.Parse($"{{\"role\":\"{request.Role}\"}}")
        });

        var newCount = participantCount + 1;
        if (role == ParticipationRole.Participante && evt.MaxParticipants.HasValue && newCount >= evt.MaxParticipants.Value)
        {
            evt.Status = EventStatus.Full;
            var geohash5 = GeoHash.Encode(evt.Location.Y, evt.Location.X, 5);
            await hub.Clients.Group($"zone:{geohash5}").SendAsync("EventFull", evt.Id.ToString(), ct);
        }

        await db.SaveChangesAsync(ct);
        return Unit.Value;
    }
}
