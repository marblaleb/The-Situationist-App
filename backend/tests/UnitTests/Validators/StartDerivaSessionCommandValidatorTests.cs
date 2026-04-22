using Api.Features.Deriva;
using FluentAssertions;

namespace UnitTests.Validators;

public class StartDerivaSessionCommandValidatorTests
{
    private static readonly StartDerivaSessionCommandValidator Validator = new();

    private static StartDerivaSessionCommand ValidCommand(string type = "Caotica") => new(
        Guid.NewGuid(),
        new StartDerivaRequest(type, 40.416, -3.703, "es"));

    [Theory]
    [InlineData("Caotica")]
    [InlineData("Poetica")]
    [InlineData("Social")]
    [InlineData("Sensorial")]
    [InlineData("caotica")]   // ignoreCase: true en el parser
    public async Task ValidType_PassesValidation(string type)
    {
        var result = await Validator.ValidateAsync(ValidCommand(type));
        result.IsValid.Should().BeTrue();
    }

    [Theory]
    [InlineData("Aleatoria")]
    [InlineData("")]
    [InlineData("Libre")]
    public async Task InvalidType_FailsValidation(string type)
    {
        var result = await Validator.ValidateAsync(ValidCommand(type));
        result.IsValid.Should().BeFalse();
        result.Errors.Should().Contain(e => e.PropertyName.Contains("Type"));
    }

    [Theory]
    [InlineData(-91)]
    [InlineData(91)]
    public async Task LatitudeOutOfRange_FailsValidation(double lat)
    {
        var cmd = ValidCommand() with { Request = ValidCommand().Request with { Latitude = lat } };
        var result = await Validator.ValidateAsync(cmd);
        result.IsValid.Should().BeFalse();
        result.Errors.Should().Contain(e => e.PropertyName.Contains("Latitude"));
    }

    [Theory]
    [InlineData(-181)]
    [InlineData(181)]
    public async Task LongitudeOutOfRange_FailsValidation(double lon)
    {
        var cmd = ValidCommand() with { Request = ValidCommand().Request with { Longitude = lon } };
        var result = await Validator.ValidateAsync(cmd);
        result.IsValid.Should().BeFalse();
        result.Errors.Should().Contain(e => e.PropertyName.Contains("Longitude"));
    }

    [Theory]
    [InlineData(-90, -180)]
    [InlineData(90, 180)]
    [InlineData(0, 0)]
    public async Task BoundaryCoordinates_PassValidation(double lat, double lon)
    {
        var cmd = ValidCommand() with { Request = ValidCommand().Request with { Latitude = lat, Longitude = lon } };
        var result = await Validator.ValidateAsync(cmd);
        result.IsValid.Should().BeTrue();
    }
}
