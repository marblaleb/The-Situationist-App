using Domain;
using Domain.Entities;
using FluentValidation;
using Infrastructure.Cache;
using Infrastructure.Persistence;
using MediatR;
using Microsoft.Extensions.Configuration;
using NetTopologySuite.Geometries;
using NGeoHash;

namespace Api.Features.Events;

public record CreateEventCommand(Guid CreatorId, CreateEventRequest Request) : IRequest<EventResponse>;

public class CreateEventCommandValidator : AbstractValidator<CreateEventCommand>
{
    public CreateEventCommandValidator(IConfiguration config)
    {
        var maxDuration = config.GetValue<int>("Events:MaxDurationMinutes", 60);
        RuleFor(x => x.Request.Title).NotEmpty().MaximumLength(200);
        RuleFor(x => x.Request.Description).NotEmpty().MaximumLength(1000);
        RuleFor(x => x.Request.DurationMinutes).InclusiveBetween(1, maxDuration);
        RuleFor(x => x.Request.RadiusMeters).InclusiveBetween(10, 5000);
        RuleFor(x => x.Request.Latitude).InclusiveBetween(-90, 90);
        RuleFor(x => x.Request.Longitude).InclusiveBetween(-180, 180);
    }
}

public class CreateEventCommandHandler(
    AppDbContext db,
    IRedisCacheService cache) : IRequestHandler<CreateEventCommand, EventResponse>
{
    public async Task<EventResponse> Handle(CreateEventCommand request, CancellationToken ct)
    {
        var req = request.Request;

        var actionType = Enum.Parse<ActionType>(req.ActionType, ignoreCase: true);
        var interventionLevel = Enum.Parse<InterventionLevel>(req.InterventionLevel, ignoreCase: true);
        var visibility = Enum.Parse<EventVisibility>(req.Visibility, ignoreCase: true);

        var location = new Point(req.Longitude, req.Latitude) { SRID = 4326 };
        var now = DateTimeOffset.UtcNow;

        var evt = new Event
        {
            Id = Guid.NewGuid(),
            CreatorId = request.CreatorId,
            Title = req.Title,
            Description = req.Description,
            ActionType = actionType,
            InterventionLevel = interventionLevel,
            Location = location,
            RadiusMeters = req.RadiusMeters,
            Visibility = visibility,
            MaxParticipants = req.MaxParticipants,
            StartsAt = req.StartsAt,
            ExpiresAt = req.StartsAt.AddMinutes(req.DurationMinutes),
            Status = EventStatus.Active,
            CreatedAt = now
        };

        db.Events.Add(evt);
        await db.SaveChangesAsync(ct);

        var geohash6 = GeoHash.Encode(req.Latitude, req.Longitude, 6);
        await cache.RemoveAsync($"events:nearby:{geohash6}");

        return EventHelpers.MapToResponse(evt, 0);
    }
}

