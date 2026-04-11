using Domain;
using Infrastructure.Persistence;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Api.Features.Profile;

public record SituationistFootprint(int EventsParticipated, int DerivasCompleted, int MissionsCompleted);

public record ProfileResponse(Guid UserId, DateTimeOffset JoinedAt, SituationistFootprint SituationistFootprint);

public record GetProfileQuery(Guid UserId) : IRequest<ProfileResponse?>;

public class GetProfileQueryHandler(AppDbContext db) : IRequestHandler<GetProfileQuery, ProfileResponse?>
{
    public async Task<ProfileResponse?> Handle(GetProfileQuery request, CancellationToken ct)
    {
        var user = await db.Users.FirstOrDefaultAsync(u => u.Id == request.UserId, ct);
        if (user is null) return null;

        var counts = await db.ActivityLogs
            .Where(a => a.UserId == request.UserId)
            .GroupBy(a => a.Type)
            .Select(g => new { Type = g.Key, Count = g.Count() })
            .ToListAsync(ct);

        int Get(ActivityLogType type) => counts.FirstOrDefault(c => c.Type == type)?.Count ?? 0;

        return new ProfileResponse(
            user.Id,
            user.CreatedAt,
            new SituationistFootprint(
                Get(ActivityLogType.EventParticipation),
                Get(ActivityLogType.DerivaCompleted),
                Get(ActivityLogType.MissionCompleted)));
    }
}
