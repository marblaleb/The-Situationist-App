using Api.Features.Events;
using Api.Features.Missions;
using Infrastructure.Persistence;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Api.Features.Profile;

public record GetUserEventsQuery(Guid UserId) : IRequest<List<EventResponse>>;

public class GetUserEventsQueryHandler(AppDbContext db)
    : IRequestHandler<GetUserEventsQuery, List<EventResponse>>
{
    public async Task<List<EventResponse>> Handle(GetUserEventsQuery request, CancellationToken ct)
    {
        var events = await db.Events
            .Where(e => e.CreatorId == request.UserId)
            .OrderByDescending(e => e.CreatedAt)
            .ToListAsync(ct);

        return events.Select(e => EventHelpers.MapToResponse(e, 0)).ToList();
    }
}

public record GetUserMissionsQuery(Guid UserId) : IRequest<List<MissionSummaryResponse>>;

public class GetUserMissionsQueryHandler(AppDbContext db)
    : IRequestHandler<GetUserMissionsQuery, List<MissionSummaryResponse>>
{
    public async Task<List<MissionSummaryResponse>> Handle(GetUserMissionsQuery request, CancellationToken ct)
    {
        var missions = await db.Missions
            .Include(m => m.Clues)
            .Where(m => m.CreatorId == request.UserId)
            .OrderByDescending(m => m.CreatedAt)
            .ToListAsync(ct);

        return missions.Select(m => new MissionSummaryResponse(
            m.Id, m.Title, m.Description,
            m.Location.Y, m.Location.X,
            m.RadiusMeters, m.Status.ToString(), m.Clues.Count)).ToList();
    }
}
