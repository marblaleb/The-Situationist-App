using Api.Features.GeoRandom;
using FluentAssertions;

namespace UnitTests.Validators;

public class GenerateGeoRandomPointCommandValidatorTests
{
    private static readonly GenerateGeoRandomPointCommandValidator Validator = new();

    private static GenerateGeoRandomPointCommand ValidCommand(
        string type = "Atractor", int radiusMeters = 2000) => new(
        Guid.NewGuid(),
        new GenerateGeoRandomPointRequest(40.416, -3.703, radiusMeters, type));

    [Theory]
    [InlineData("Atractor")]
    [InlineData("Vacio")]
    [InlineData("Anomalia")]
    [InlineData("atractor")]
    public async Task ValidType_PassesValidation(string type)
    {
        var result = await Validator.ValidateAsync(ValidCommand(type));
        result.IsValid.Should().BeTrue();
    }

    [Theory]
    [InlineData("Aleatorio")]
    [InlineData("")]
    public async Task InvalidType_FailsValidation(string type)
    {
        var result = await Validator.ValidateAsync(ValidCommand(type));
        result.IsValid.Should().BeFalse();
        result.Errors.Should().Contain(e => e.PropertyName.Contains("Type"));
    }

    [Theory]
    [InlineData(499)]
    [InlineData(5001)]
    public async Task RadiusOutOfRange_FailsValidation(int radius)
    {
        var result = await Validator.ValidateAsync(ValidCommand(radiusMeters: radius));
        result.IsValid.Should().BeFalse();
        result.Errors.Should().Contain(e => e.PropertyName.Contains("RadiusMeters"));
    }

    [Theory]
    [InlineData(500)]
    [InlineData(5000)]
    public async Task RadiusBoundaries_PassValidation(int radius)
    {
        var result = await Validator.ValidateAsync(ValidCommand(radiusMeters: radius));
        result.IsValid.Should().BeTrue();
    }
}
