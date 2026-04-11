using Domain;
using Infrastructure.Cache;
using Infrastructure.Persistence;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using NGeoHash;
using Infrastructure.SignalR;

namespace Infrastructure.Workers;

public class EventExpirationWorker(
    IServiceScopeFactory scopeFactory,
    ILogger<EventExpirationWorker> logger) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await ProcessExpiredEventsAsync(stoppingToken);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Error processing expired events");
            }
            await Task.Delay(TimeSpan.FromSeconds(30), stoppingToken);
        }
    }

    private async Task ProcessExpiredEventsAsync(CancellationToken ct)
    {
        using var scope = scopeFactory.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var cache = scope.ServiceProvider.GetRequiredService<IRedisCacheService>();
        var hub = scope.ServiceProvider.GetRequiredService<IHubContext<EventHub>>();

        var now = DateTimeOffset.UtcNow;
        var expiredEvents = await db.Events
            .Where(e => e.ExpiresAt <= now && e.Status == EventStatus.Active)
            .ToListAsync(ct);

        foreach (var e in expiredEvents)
        {
            e.Status = EventStatus.Expired;

            var geohash6 = GeoHash.Encode(e.Location.Y, e.Location.X, 6);
            var geohash5 = geohash6[..5];

            await cache.RemoveAsync($"events:nearby:{geohash6}");
            await hub.Clients.Group($"zone:{geohash5}").SendAsync("EventExpired", e.Id.ToString(), ct);

            logger.LogInformation("Event {EventId} expired", e.Id);
        }

        if (expiredEvents.Count > 0)
            await db.SaveChangesAsync(ct);
    }
}
