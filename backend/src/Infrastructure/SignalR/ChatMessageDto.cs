namespace Infrastructure.SignalR;

public record ChatMessageDto(
    Guid Id,
    Guid EventId,
    Guid SenderId,
    string SenderUsername,
    string Content,
    DateTimeOffset SentAt);
