using Infrastructure.Persistence;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Api.Features.Profile;

public record ActivityLogEntry(
    Guid Id,
    string Type,
    Guid ReferenceId,
    DateTimeOffset OccurredAt);

public record ActivityLogPage(List<ActivityLogEntry> Items, string? NextCursor);

public record GetActivityLogQuery(Guid UserId, string? Cursor, int PageSize = 20) : IRequest<ActivityLogPage>;

public class GetActivityLogQueryHandler(AppDbContext db) : IRequestHandler<GetActivityLogQuery, ActivityLogPage>
{
    public async Task<ActivityLogPage> Handle(GetActivityLogQuery request, CancellationToken ct)
    {
        // Cursor encodes: OccurredAt|Id
        DateTimeOffset? cursorDate = null;
        Guid? cursorId = null;

        if (request.Cursor is not null)
        {
            var parts = System.Text.Encoding.UTF8
                .GetString(Convert.FromBase64String(request.Cursor))
                .Split('|');
            if (parts.Length == 2)
            {
                cursorDate = DateTimeOffset.Parse(parts[0]);
                cursorId = Guid.Parse(parts[1]);
            }
        }

        var query = db.ActivityLogs
            .Where(a => a.UserId == request.UserId);

        if (cursorDate.HasValue && cursorId.HasValue)
        {
            query = query.Where(a =>
                a.OccurredAt < cursorDate.Value ||
                (a.OccurredAt == cursorDate.Value && a.Id.CompareTo(cursorId.Value) < 0));
        }

        var items = await query
            .OrderByDescending(a => a.OccurredAt)
            .ThenByDescending(a => a.Id)
            .Take(request.PageSize + 1)
            .Select(a => new ActivityLogEntry(a.Id, a.Type.ToString(), a.ReferenceId, a.OccurredAt))
            .ToListAsync(ct);

        string? nextCursor = null;
        if (items.Count > request.PageSize)
        {
            items.RemoveAt(items.Count - 1);
            var last = items.Last();
            nextCursor = Convert.ToBase64String(
                System.Text.Encoding.UTF8.GetBytes($"{last.OccurredAt:O}|{last.Id}"));
        }

        return new ActivityLogPage(items, nextCursor);
    }
}
