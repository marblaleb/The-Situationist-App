using Api.Features.Events;
using FluentAssertions;

namespace UnitTests.Validators;

public class ParticipateInEventCommandValidatorTests
{
    private static readonly ParticipateInEventCommandValidator Validator = new();

    [Theory]
    [InlineData("Participante")]
    [InlineData("Observador")]
    public async Task ValidRole_PassesValidation(string role)
    {
        var cmd = new ParticipateInEventCommand(Guid.NewGuid(), Guid.NewGuid(), role);
        var result = await Validator.ValidateAsync(cmd);
        result.IsValid.Should().BeTrue();
    }

    [Theory]
    [InlineData("participante")]   // case-sensitive
    [InlineData("observador")]
    [InlineData("Admin")]
    [InlineData("")]
    [InlineData("  ")]
    public async Task InvalidRole_FailsValidation(string role)
    {
        var cmd = new ParticipateInEventCommand(Guid.NewGuid(), Guid.NewGuid(), role);
        var result = await Validator.ValidateAsync(cmd);
        result.IsValid.Should().BeFalse();
        result.Errors.Should().Contain(e => e.PropertyName.Contains("Role"));
    }
}
