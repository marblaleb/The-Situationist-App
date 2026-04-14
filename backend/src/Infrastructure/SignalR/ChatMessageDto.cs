namespace Infrastructure.SignalR;

public record ChatMessageDto(
    Guid Id,
    Guid EventId,
    Guid SenderId,
    string SenderEmail,
    string Content,
    DateTimeOffset SentAt);
