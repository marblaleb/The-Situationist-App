using Api.Features.Events;
using Domain;
using Domain.Entities;
using FluentAssertions;
using NetTopologySuite.Geometries;

namespace UnitTests.Helpers;

public class EventHelpersTests
{
    private static Event BuildEvent() => new()
    {
        Id = Guid.NewGuid(),
        CreatorId = Guid.NewGuid(),
        Title = "Evento test",
        Description = "Descripción de prueba",
        ActionType = ActionType.Social,
        InterventionLevel = InterventionLevel.Bajo,
        Location = new Point(x: -3.703, y: 40.416) { SRID = 4326 },
        RadiusMeters = 200,
        Visibility = EventVisibility.Public,
        MaxParticipants = 10,
        StartsAt = DateTimeOffset.UtcNow,
        ExpiresAt = DateTimeOffset.UtcNow.AddHours(1),
        Status = EventStatus.Active,
        CreatedAt = DateTimeOffset.UtcNow
    };

    [Fact]
    public void MapToResponse_PreservesIdAndCreatorId()
    {
        var evt = BuildEvent();

        var result = EventHelpers.MapToResponse(evt, 0);

        result.Id.Should().Be(evt.Id);
        result.CreatorId.Should().Be(evt.CreatorId);
    }

    [Fact]
    public void MapToResponse_UsesPointYAsLatitude()
    {
        // Point(x=lon, y=lat) — el Y es la latitud
        var evt = BuildEvent();

        var result = EventHelpers.MapToResponse(evt, 0);

        result.CentroidLatitude.Should().Be(evt.Location.Y);
    }

    [Fact]
    public void MapToResponse_UsesPointXAsLongitude()
    {
        var evt = BuildEvent();

        var result = EventHelpers.MapToResponse(evt, 0);

        result.CentroidLongitude.Should().Be(evt.Location.X);
    }

    [Fact]
    public void MapToResponse_PropagatesParticipantCount()
    {
        var evt = BuildEvent();

        var result = EventHelpers.MapToResponse(evt, 7);

        result.ParticipantCount.Should().Be(7);
    }

    [Theory]
    [InlineData(0)]
    [InlineData(42)]
    public void MapToResponse_ParticipantCountMatchesArgument(int count)
    {
        var evt = BuildEvent();

        var result = EventHelpers.MapToResponse(evt, count);

        result.ParticipantCount.Should().Be(count);
    }

    [Fact]
    public void MapToResponse_ConvertsEnumsToString()
    {
        var evt = BuildEvent();

        var result = EventHelpers.MapToResponse(evt, 0);

        result.ActionType.Should().Be("Social");
        result.InterventionLevel.Should().Be("Bajo");
        result.Visibility.Should().Be("Public");
        result.Status.Should().Be("Active");
    }

    [Fact]
    public void MapToResponse_MapsScalarFields()
    {
        var evt = BuildEvent();

        var result = EventHelpers.MapToResponse(evt, 0);

        result.Title.Should().Be(evt.Title);
        result.Description.Should().Be(evt.Description);
        result.RadiusMeters.Should().Be(evt.RadiusMeters);
        result.MaxParticipants.Should().Be(evt.MaxParticipants);
        result.StartsAt.Should().Be(evt.StartsAt);
        result.ExpiresAt.Should().Be(evt.ExpiresAt);
    }
}
