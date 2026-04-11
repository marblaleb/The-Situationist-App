using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace Infrastructure.SignalR;

[Authorize]
public class EventHub : Hub
{
    public async Task JoinZone(string geohash5)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, $"zone:{geohash5}");
    }

    public async Task LeaveZone(string geohash5)
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"zone:{geohash5}");
    }
}
