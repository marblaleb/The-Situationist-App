using Api.Features.GeoRandom;
using FluentAssertions;
using Infrastructure.Cache;
using Infrastructure.Geo;
using NSubstitute;
using UnitTests.TestUtils;

namespace UnitTests.Handlers;

public class GenerateGeoRandomPointCommandHandlerTests
{
    private static GenerateGeoRandomPointCommand ValidCommand(Guid? userId = null) => new(
        userId ?? Guid.NewGuid(),
        new GenerateGeoRandomPointRequest(40.4168, -3.7038, 2000, "Atractor"));

    [Fact]
    public async Task Handle_ReturnsPoint_WhenDataAvailable()
    {
        var cache = Substitute.For<IGeoRandomCacheService>();
        var throttle = Substitute.For<IRedisCacheService>();
        throttle.ExistsAsync(Arg.Any<string>()).Returns(false);
        cache.GetOrFetchAsync(Arg.Any<double>(), Arg.Any<double>(), Arg.Any<CancellationToken>())
            .Returns(new OverpassResult([new PoiPoint(40.42, -3.70)], []));

        var handler = new GenerateGeoRandomPointCommandHandler(
            cache, new KdeCalculator(new SeededRandomSource(1)), throttle);

        var result = await handler.Handle(ValidCommand(), CancellationToken.None);

        result.Type.Should().Be("Atractor");
        await throttle.Received(1).SetAsync(Arg.Any<string>(), "1", Arg.Any<TimeSpan>());
    }

    [Fact]
    public async Task Handle_Throws_WhenThrottled()
    {
        var cache = Substitute.For<IGeoRandomCacheService>();
        var throttle = Substitute.For<IRedisCacheService>();
        throttle.ExistsAsync(Arg.Any<string>()).Returns(true);

        var handler = new GenerateGeoRandomPointCommandHandler(
            cache, new KdeCalculator(new SeededRandomSource(1)), throttle);

        var act = () => handler.Handle(ValidCommand(), CancellationToken.None);

        await act.Should().ThrowAsync<RateLimitExceededException>();
    }

    [Fact]
    public async Task Handle_Throws_WhenOverpassUnavailable()
    {
        var cache = Substitute.For<IGeoRandomCacheService>();
        var throttle = Substitute.For<IRedisCacheService>();
        throttle.ExistsAsync(Arg.Any<string>()).Returns(false);
        cache.GetOrFetchAsync(Arg.Any<double>(), Arg.Any<double>(), Arg.Any<CancellationToken>())
            .Returns(Task.FromException<OverpassResult>(new HttpRequestException("boom")));

        var handler = new GenerateGeoRandomPointCommandHandler(
            cache, new KdeCalculator(new SeededRandomSource(1)), throttle);

        var act = () => handler.Handle(ValidCommand(), CancellationToken.None);

        await act.Should().ThrowAsync<GeoDataUnavailableException>();
    }
}
