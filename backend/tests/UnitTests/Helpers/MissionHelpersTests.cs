using Api.Features.Missions;
using Domain;
using Domain.Entities;
using FluentAssertions;
using NetTopologySuite.Geometries;

namespace UnitTests.Helpers;

public class MissionHelpersTests
{
    private static Clue BuildClue(bool withHint = true, bool withLocation = true) => new()
    {
        Id = Guid.NewGuid(),
        MissionId = Guid.NewGuid(),
        Order = 2,
        Type = ClueType.Textual,
        Content = "Busca el mural en la esquina",
        Hint = withHint ? "Está cerca del mercado" : null,
        AnswerHash = "fakehash",
        IsOptional = false,
        Location = withLocation ? new Point(x: -3.703, y: 40.416) { SRID = 4326 } : null
    };

    [Fact]
    public void MapClue_PreservesIdAndOrder()
    {
        var clue = BuildClue();

        var result = MissionHelpers.MapClue(clue);

        result.Id.Should().Be(clue.Id);
        result.Order.Should().Be(clue.Order);
    }

    [Fact]
    public void MapClue_ConvertsTypeToString()
    {
        var clue = BuildClue();

        var result = MissionHelpers.MapClue(clue);

        result.Type.Should().Be("Textual");
    }

    [Fact]
    public void MapClue_HasHintIsTrueWhenHintIsNotNull()
    {
        var clue = BuildClue(withHint: true);

        var result = MissionHelpers.MapClue(clue);

        result.HasHint.Should().BeTrue();
    }

    [Fact]
    public void MapClue_HasHintIsFalseWhenHintIsNull()
    {
        var clue = BuildClue(withHint: false);

        var result = MissionHelpers.MapClue(clue);

        result.HasHint.Should().BeFalse();
    }

    [Fact]
    public void MapClue_MapsLocationYAsLatitude()
    {
        var clue = BuildClue(withLocation: true);

        var result = MissionHelpers.MapClue(clue);

        result.Latitude.Should().Be(clue.Location!.Y);
    }

    [Fact]
    public void MapClue_MapsLocationXAsLongitude()
    {
        var clue = BuildClue(withLocation: true);

        var result = MissionHelpers.MapClue(clue);

        result.Longitude.Should().Be(clue.Location!.X);
    }

    [Fact]
    public void MapClue_NullLocationProducesNullCoordinates()
    {
        var clue = BuildClue(withLocation: false);

        var result = MissionHelpers.MapClue(clue);

        result.Latitude.Should().BeNull();
        result.Longitude.Should().BeNull();
    }

    [Fact]
    public void MapClue_PreservesContentAndIsOptional()
    {
        var clue = BuildClue();

        var result = MissionHelpers.MapClue(clue);

        result.Content.Should().Be(clue.Content);
        result.IsOptional.Should().Be(clue.IsOptional);
    }
}
