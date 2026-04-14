namespace Domain.Entities;

public class ChatMessage
{
    public Guid Id { get; set; }
    public Guid EventId { get; set; }
    public Guid SenderId { get; set; }
    public string Content { get; set; } = string.Empty;
    public DateTimeOffset SentAt { get; set; }

    public Event Event { get; set; } = null!;
    public User Sender { get; set; } = null!;
}
