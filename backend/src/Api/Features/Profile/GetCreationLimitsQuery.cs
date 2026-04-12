using Infrastructure.Persistence;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Api.Features.Profile;

public record GetCreationLimitsQuery(Guid UserId) : IRequest<CreationLimitsResponse>;

public record CreationLimitsResponse(int EventsToday, int MissionsToday, int DailyLimit);

public class GetCreationLimitsQueryHandler(AppDbContext db)
    : IRequestHandler<GetCreationLimitsQuery, CreationLimitsResponse>
{
    private const int DailyLimit = 2;

    public async Task<CreationLimitsResponse> Handle(
        GetCreationLimitsQuery request, CancellationToken ct)
    {
        var todayUtc = new DateTimeOffset(DateTimeOffset.UtcNow.Date, TimeSpan.Zero);

        var eventsToday = await db.Events.CountAsync(
            e => e.CreatorId == request.UserId && e.CreatedAt >= todayUtc, ct);

        var missionsToday = await db.Missions.CountAsync(
            m => m.CreatorId == request.UserId && m.CreatedAt >= todayUtc, ct);

        return new CreationLimitsResponse(eventsToday, missionsToday, DailyLimit);
    }
}
