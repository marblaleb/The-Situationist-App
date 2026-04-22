using Api.Features.Missions;
using FluentAssertions;

namespace UnitTests.Validators;

public class CreateMissionCommandValidatorTests
{
    private static readonly CreateMissionCommandValidator Validator = new();

    private static CreateMissionCommand ValidCommand() => new(
        Guid.NewGuid(),
        new CreateMissionRequest(
            Title: "Misión urbana",
            Description: "Sigue las pistas por el barrio",
            Latitude: 40.416,
            Longitude: -3.703,
            RadiusMeters: 500,
            Clues:
            [
                new CreateClueRequest(
                    Order: 1,
                    Type: "Textual",
                    Content: "Encuentra el mural rojo",
                    Hint: null,
                    Answer: "paloma",
                    IsOptional: false,
                    Latitude: null,
                    Longitude: null)
            ]));

    [Fact]
    public async Task ValidCommand_PassesValidation()
    {
        var result = await Validator.ValidateAsync(ValidCommand());
        result.IsValid.Should().BeTrue();
    }

    [Fact]
    public async Task EmptyTitle_FailsValidation()
    {
        var cmd = ValidCommand() with { Request = ValidCommand().Request with { Title = "" } };
        var result = await Validator.ValidateAsync(cmd);
        result.IsValid.Should().BeFalse();
        result.Errors.Should().Contain(e => e.PropertyName.Contains("Title"));
    }

    [Fact]
    public async Task TitleExceeding200Chars_FailsValidation()
    {
        var cmd = ValidCommand() with { Request = ValidCommand().Request with { Title = new string('a', 201) } };
        var result = await Validator.ValidateAsync(cmd);
        result.IsValid.Should().BeFalse();
        result.Errors.Should().Contain(e => e.PropertyName.Contains("Title"));
    }

    [Fact]
    public async Task EmptyDescription_FailsValidation()
    {
        var cmd = ValidCommand() with { Request = ValidCommand().Request with { Description = "" } };
        var result = await Validator.ValidateAsync(cmd);
        result.IsValid.Should().BeFalse();
        result.Errors.Should().Contain(e => e.PropertyName.Contains("Description"));
    }

    [Fact]
    public async Task DescriptionExceeding1000Chars_FailsValidation()
    {
        var cmd = ValidCommand() with { Request = ValidCommand().Request with { Description = new string('x', 1001) } };
        var result = await Validator.ValidateAsync(cmd);
        result.IsValid.Should().BeFalse();
        result.Errors.Should().Contain(e => e.PropertyName.Contains("Description"));
    }

    [Fact]
    public async Task NoClues_FailsValidation()
    {
        var cmd = ValidCommand() with { Request = ValidCommand().Request with { Clues = [] } };
        var result = await Validator.ValidateAsync(cmd);
        result.IsValid.Should().BeFalse();
        result.Errors.Should().Contain(e => e.PropertyName.Contains("Clues") && e.ErrorMessage.Contains("clue"));
    }

    [Fact]
    public async Task ClueWithEmptyContent_FailsValidation()
    {
        var badClue = new CreateClueRequest(1, "Textual", Content: "", Hint: null, Answer: "resp", false, null, null);
        var cmd = ValidCommand() with { Request = ValidCommand().Request with { Clues = [badClue] } };
        var result = await Validator.ValidateAsync(cmd);
        result.IsValid.Should().BeFalse();
        result.Errors.Should().Contain(e => e.PropertyName.Contains("Content"));
    }

    [Fact]
    public async Task ClueWithEmptyAnswer_FailsValidation()
    {
        var badClue = new CreateClueRequest(1, "Textual", "Contenido válido", null, Answer: "", false, null, null);
        var cmd = ValidCommand() with { Request = ValidCommand().Request with { Clues = [badClue] } };
        var result = await Validator.ValidateAsync(cmd);
        result.IsValid.Should().BeFalse();
        result.Errors.Should().Contain(e => e.PropertyName.Contains("Answer"));
    }

    [Fact]
    public async Task MultipleClues_AllValid_PassesValidation()
    {
        var clues = new List<CreateClueRequest>
        {
            new(1, "Textual", "Primera pista", null, "respuesta1", false, null, null),
            new(2, "Sensorial", "Segunda pista", "pista", "respuesta2", true, 40.416, -3.703),
        };
        var cmd = ValidCommand() with { Request = ValidCommand().Request with { Clues = clues } };
        var result = await Validator.ValidateAsync(cmd);
        result.IsValid.Should().BeTrue();
    }
}
