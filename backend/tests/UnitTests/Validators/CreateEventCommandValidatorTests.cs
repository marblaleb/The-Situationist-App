using Api.Features.Events;
using FluentAssertions;
using Microsoft.Extensions.Configuration;

namespace UnitTests.Validators;

public class CreateEventCommandValidatorTests
{
    private static CreateEventCommandValidator BuildValidator(int maxDuration = 60)
    {
        var config = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["Events:MaxDurationMinutes"] = maxDuration.ToString()
            })
            .Build();
        return new CreateEventCommandValidator(config);
    }

    private static CreateEventCommand ValidCommand() => new(
        Guid.NewGuid(),
        new CreateEventRequest(
            Title: "Deriva nocturna",
            Description: "Una exploración psicogeográfica del barrio",
            ActionType: "Social",
            InterventionLevel: "Bajo",
            Latitude: 40.416,
            Longitude: -3.703,
            RadiusMeters: 200,
            Visibility: "Public",
            MaxParticipants: null,
            StartsAt: DateTimeOffset.UtcNow.AddHours(1),
            DurationMinutes: 45));

    [Fact]
    public async Task ValidCommand_PassesValidation()
    {
        var result = await BuildValidator().ValidateAsync(ValidCommand());
        result.IsValid.Should().BeTrue();
    }

    [Fact]
    public async Task EmptyTitle_FailsValidation()
    {
        var cmd = ValidCommand() with { Request = ValidCommand().Request with { Title = "" } };
        var result = await BuildValidator().ValidateAsync(cmd);
        result.IsValid.Should().BeFalse();
        result.Errors.Should().Contain(e => e.PropertyName.Contains("Title"));
    }

    [Fact]
    public async Task TitleExceeding200Chars_FailsValidation()
    {
        var longTitle = new string('a', 201);
        var cmd = ValidCommand() with { Request = ValidCommand().Request with { Title = longTitle } };
        var result = await BuildValidator().ValidateAsync(cmd);
        result.IsValid.Should().BeFalse();
        result.Errors.Should().Contain(e => e.PropertyName.Contains("Title"));
    }

    [Fact]
    public async Task EmptyDescription_FailsValidation()
    {
        var cmd = ValidCommand() with { Request = ValidCommand().Request with { Description = "" } };
        var result = await BuildValidator().ValidateAsync(cmd);
        result.IsValid.Should().BeFalse();
        result.Errors.Should().Contain(e => e.PropertyName.Contains("Description"));
    }

    [Fact]
    public async Task DescriptionExceeding1000Chars_FailsValidation()
    {
        var longDesc = new string('x', 1001);
        var cmd = ValidCommand() with { Request = ValidCommand().Request with { Description = longDesc } };
        var result = await BuildValidator().ValidateAsync(cmd);
        result.IsValid.Should().BeFalse();
        result.Errors.Should().Contain(e => e.PropertyName.Contains("Description"));
    }

    [Fact]
    public async Task DurationZero_FailsValidation()
    {
        var cmd = ValidCommand() with { Request = ValidCommand().Request with { DurationMinutes = 0 } };
        var result = await BuildValidator().ValidateAsync(cmd);
        result.IsValid.Should().BeFalse();
        result.Errors.Should().Contain(e => e.PropertyName.Contains("DurationMinutes"));
    }

    [Fact]
    public async Task DurationExceedsMax_FailsValidation()
    {
        var cmd = ValidCommand() with { Request = ValidCommand().Request with { DurationMinutes = 61 } };
        var result = await BuildValidator(maxDuration: 60).ValidateAsync(cmd);
        result.IsValid.Should().BeFalse();
        result.Errors.Should().Contain(e => e.PropertyName.Contains("DurationMinutes"));
    }

    [Fact]
    public async Task DurationEqualsMax_PassesValidation()
    {
        var cmd = ValidCommand() with { Request = ValidCommand().Request with { DurationMinutes = 60 } };
        var result = await BuildValidator(maxDuration: 60).ValidateAsync(cmd);
        result.IsValid.Should().BeTrue();
    }

    [Fact]
    public async Task RadiusBelowMinimum_FailsValidation()
    {
        var cmd = ValidCommand() with { Request = ValidCommand().Request with { RadiusMeters = 9 } };
        var result = await BuildValidator().ValidateAsync(cmd);
        result.IsValid.Should().BeFalse();
        result.Errors.Should().Contain(e => e.PropertyName.Contains("RadiusMeters"));
    }

    [Fact]
    public async Task RadiusAboveMaximum_FailsValidation()
    {
        var cmd = ValidCommand() with { Request = ValidCommand().Request with { RadiusMeters = 5001 } };
        var result = await BuildValidator().ValidateAsync(cmd);
        result.IsValid.Should().BeFalse();
        result.Errors.Should().Contain(e => e.PropertyName.Contains("RadiusMeters"));
    }

    [Theory]
    [InlineData(10)]
    [InlineData(5000)]
    public async Task RadiusAtBoundaries_PassesValidation(int radius)
    {
        var cmd = ValidCommand() with { Request = ValidCommand().Request with { RadiusMeters = radius } };
        var result = await BuildValidator().ValidateAsync(cmd);
        result.IsValid.Should().BeTrue();
    }

    [Theory]
    [InlineData(-91)]
    [InlineData(91)]
    public async Task LatitudeOutOfRange_FailsValidation(double lat)
    {
        var cmd = ValidCommand() with { Request = ValidCommand().Request with { Latitude = lat } };
        var result = await BuildValidator().ValidateAsync(cmd);
        result.IsValid.Should().BeFalse();
        result.Errors.Should().Contain(e => e.PropertyName.Contains("Latitude"));
    }

    [Theory]
    [InlineData(-181)]
    [InlineData(181)]
    public async Task LongitudeOutOfRange_FailsValidation(double lon)
    {
        var cmd = ValidCommand() with { Request = ValidCommand().Request with { Longitude = lon } };
        var result = await BuildValidator().ValidateAsync(cmd);
        result.IsValid.Should().BeFalse();
        result.Errors.Should().Contain(e => e.PropertyName.Contains("Longitude"));
    }
}
