using Infrastructure.Ai;
using MediatR;
using NGeoHash;

namespace Api.Features.Events;

public record GenerateEventSuggestionCommand(
    string ActionType,
    string InterventionLevel,
    double? Latitude,
    double? Longitude) : IRequest<EventDraft>;

public class GenerateEventSuggestionCommandHandler(IAnthropicClient ai)
    : IRequestHandler<GenerateEventSuggestionCommand, EventDraft>
{
    public async Task<EventDraft> Handle(GenerateEventSuggestionCommand request, CancellationToken ct)
    {
        string? locationHint = null;
        if (request.Latitude.HasValue && request.Longitude.HasValue)
            locationHint = GeoHash.Encode(request.Latitude.Value, request.Longitude.Value, 5);

        var context = new EventContext(request.ActionType, request.InterventionLevel, locationHint);
        return await ai.GenerateEventSuggestionAsync(context, ct);
    }
}
