using FluentAssertions;
using Infrastructure.Ai;

namespace UnitTests;

public class LocalContentServiceTests
{
    private readonly LocalContentService _sut = new();

    [Fact]
    public async Task GenerateEventSuggestion_ReturnsNonEmptyTitle()
    {
        var ctx = new EventContext("Performativa", "Bajo", null);
        var result = await _sut.GenerateEventSuggestionAsync(ctx);
        result.Title.Should().NotBeNullOrWhiteSpace();
    }

    [Fact]
    public async Task GenerateEventSuggestion_ReturnsNonEmptyDescription()
    {
        var ctx = new EventContext("Social", "Medio", "u30d");
        var result = await _sut.GenerateEventSuggestionAsync(ctx);
        result.Description.Should().NotBeNullOrWhiteSpace();
    }

    [Fact]
    public async Task GenerateEventSuggestion_ActionTypeMatchesRequest()
    {
        var ctx = new EventContext("Sensorial", "Alto", null);
        var result = await _sut.GenerateEventSuggestionAsync(ctx);
        result.ActionType.Should().Be("Sensorial");
    }

    [Theory]
    [InlineData("Caotica")]
    [InlineData("Poetica")]
    [InlineData("Social")]
    [InlineData("Sensorial")]
    public async Task GenerateDerivaInstruction_ReturnsNonEmptyContent(string type)
    {
        var ctx = new DerivaContext(type, "tarde", "u30d1", null, "es");
        var result = await _sut.GenerateDerivaInstructionAsync(ctx);
        result.Content.Should().NotBeNullOrWhiteSpace();
    }

    [Fact]
    public async Task GenerateDerivaInstruction_UnknownTypeFallsBackToCaotica()
    {
        var ctx = new DerivaContext("Desconocida", "mañana", "u30d1", null, "es");
        var result = await _sut.GenerateDerivaInstructionAsync(ctx);
        result.Content.Should().NotBeNullOrWhiteSpace();
    }

    [Fact]
    public async Task ModerateContent_ReturnsAllowed()
    {
        var result = await _sut.ModerateContentAsync("Una reunión en la plaza para explorar el barrio");
        result.IsAllowed.Should().BeTrue();
    }

    [Fact]
    public async Task ModerateContent_DoesNotThrow()
    {
        var act = async () => await _sut.ModerateContentAsync("cualquier texto");
        await act.Should().NotThrowAsync();
    }

    [Fact]
    public async Task GenerateEventSuggestion_VariesOutputAcrossCalls()
    {
        var titles = new HashSet<string>();
        for (int i = 0; i < 15; i++)
        {
            var ctx = new EventContext("Poetica", "Bajo", null);
            var r = await _sut.GenerateEventSuggestionAsync(ctx);
            titles.Add(r.Title);
        }
        // Pool has many entries — at least 3 distinct titles in 15 calls
        titles.Count.Should().BeGreaterThanOrEqualTo(3);
    }
}
