using Infrastructure.Persistence;
using Infrastructure.SignalR;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Api.Features.Chat;

public record GetChatMessagesQuery(Guid EventId) : IRequest<List<ChatMessageDto>>;

public class GetChatMessagesQueryHandler(AppDbContext db)
    : IRequestHandler<GetChatMessagesQuery, List<ChatMessageDto>>
{
    public async Task<List<ChatMessageDto>> Handle(
        GetChatMessagesQuery request,
        CancellationToken ct)
    {
        var messages = await db.ChatMessages
            .Where(m => m.EventId == request.EventId)
            .Include(m => m.Sender)
            .OrderByDescending(m => m.SentAt)
            .Take(50)
            .Select(m => new ChatMessageDto(
                m.Id, m.EventId, m.SenderId,
                m.Sender.Email, m.Content, m.SentAt))
            .ToListAsync(ct);

        messages.Reverse(); // oldest first for display
        return messages;
    }
}
