using Domain;
using Domain.Entities;
using FluentValidation;
using Infrastructure.Cache;
using Infrastructure.Persistence;
using MediatR;
using NetTopologySuite.Geometries;
using NGeoHash;

namespace Api.Features.Missions;

public record CreateMissionCommand(Guid CreatorId, CreateMissionRequest Request) : IRequest<MissionSummaryResponse>;

public class CreateMissionCommandValidator : AbstractValidator<CreateMissionCommand>
{
    public CreateMissionCommandValidator()
    {
        RuleFor(x => x.Request.Title).NotEmpty().MaximumLength(200);
        RuleFor(x => x.Request.Description).NotEmpty().MaximumLength(1000);
        RuleFor(x => x.Request.Clues).NotEmpty().WithMessage("Mission must have at least one clue");
        RuleForEach(x => x.Request.Clues).ChildRules(clue =>
        {
            clue.RuleFor(c => c.Content).NotEmpty();
            clue.RuleFor(c => c.Answer).NotEmpty();
        });
    }
}

public class CreateMissionCommandHandler(
    AppDbContext db,
    IRedisCacheService cache) : IRequestHandler<CreateMissionCommand, MissionSummaryResponse>
{
    public async Task<MissionSummaryResponse> Handle(CreateMissionCommand request, CancellationToken ct)
    {
        var req = request.Request;
        var location = new Point(req.Longitude, req.Latitude) { SRID = 4326 };

        var mission = new Mission
        {
            Id = Guid.NewGuid(),
            CreatorId = request.CreatorId,
            Title = req.Title,
            Description = req.Description,
            Location = location,
            RadiusMeters = req.RadiusMeters,
            Status = MissionStatus.Active,
            CreatedAt = DateTimeOffset.UtcNow
        };

        foreach (var c in req.Clues)
        {
            Point? clueLocation = c.Latitude.HasValue && c.Longitude.HasValue
                ? new Point(c.Longitude.Value, c.Latitude.Value) { SRID = 4326 }
                : null;

            mission.Clues.Add(new Clue
            {
                Id = Guid.NewGuid(),
                MissionId = mission.Id,
                Order = c.Order,
                Type = Enum.Parse<ClueType>(c.Type, ignoreCase: true),
                Content = c.Content,
                Hint = c.Hint,
                AnswerHash = BCrypt.Net.BCrypt.HashPassword(c.Answer.Trim().ToLowerInvariant()),
                IsOptional = c.IsOptional,
                Location = clueLocation
            });
        }

        db.Missions.Add(mission);
        await db.SaveChangesAsync(ct);

        var geohash6 = GeoHash.Encode(req.Latitude, req.Longitude, 6);
        await cache.RemoveAsync($"missions:nearby:{geohash6}");

        return new MissionSummaryResponse(
            mission.Id, mission.Title, mission.Description,
            mission.Location.Y, mission.Location.X,
            mission.RadiusMeters, mission.Status.ToString(), mission.Clues.Count);
    }
}
