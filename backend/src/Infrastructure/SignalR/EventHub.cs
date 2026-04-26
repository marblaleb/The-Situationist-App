using Domain.Entities;
using Infrastructure.Persistence;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using System.Security.Claims;

namespace Infrastructure.SignalR;

[Authorize]
public class EventHub(AppDbContext db) : Hub
{
    public async Task JoinZone(string geohash5)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, $"zone:{geohash5}");
    }

    public async Task LeaveZone(string geohash5)
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"zone:{geohash5}");
    }

    public async Task JoinEvent(string eventId)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, $"event:{eventId}");
    }

    public async Task LeaveEvent(string eventId)
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"event:{eventId}");
    }

    public async Task SendMessage(string eventId, string content)
    {
        var userIdStr = Context.User?.FindFirst("sub")?.Value;
        if (userIdStr is null || string.IsNullOrWhiteSpace(content)) return;

        var userId = Guid.Parse(userIdStr);
        var user = await db.Users.FindAsync(userId);
        if (user is null) return;

        var message = new ChatMessage
        {
            Id = Guid.NewGuid(),
            EventId = Guid.Parse(eventId),
            SenderId = userId,
            Content = content.Trim(),
            SentAt = DateTimeOffset.UtcNow,
        };

        db.ChatMessages.Add(message);
        await db.SaveChangesAsync();

        var dto = new ChatMessageDto(
            message.Id,
            message.EventId,
            userId,
            user.Username ?? user.Email,
            message.Content,
            message.SentAt);

        await Clients.Group($"event:{eventId}").SendAsync("ReceiveMessage", dto);
    }
}
