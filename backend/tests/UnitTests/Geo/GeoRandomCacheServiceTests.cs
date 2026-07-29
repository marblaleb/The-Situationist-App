using System.Text.Json;
using FluentAssertions;
using Infrastructure.Cache;
using Infrastructure.Geo;
using NGeoHash;
using NSubstitute;

namespace UnitTests.Geo;

public class GeoRandomCacheServiceTests
{
    [Fact]
    public async Task GetOrFetchAsync_ReturnsCachedValue_WhenPresent()
    {
        var redis = Substitute.For<IRedisCacheService>();
        var overpass = Substitute.For<IOverpassClient>();
        var cachedResult = new OverpassResult([new PoiPoint(40.42, -3.70)], []);
        redis.GetAsync(Arg.Any<string>()).Returns(JsonSerializer.Serialize(cachedResult));

        var service = new GeoRandomCacheService(redis, overpass);
        var result = await service.GetOrFetchAsync(40.4168, -3.7038);

        result.Pois.Should().ContainSingle(p => p.Lat == 40.42 && p.Lng == -3.70);
        await overpass.DidNotReceive().FetchAsync(
            Arg.Any<double>(), Arg.Any<double>(), Arg.Any<int>(), Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task GetOrFetchAsync_FetchesAndCaches_WhenMissing()
    {
        var redis = Substitute.For<IRedisCacheService>();
        var overpass = Substitute.For<IOverpassClient>();
        redis.GetAsync(Arg.Any<string>()).Returns((string?)null);
        var freshResult = new OverpassResult([new PoiPoint(40.43, -3.71)], []);
        overpass.FetchAsync(Arg.Any<double>(), Arg.Any<double>(), Arg.Any<int>(), Arg.Any<CancellationToken>())
            .Returns(freshResult);

        var service = new GeoRandomCacheService(redis, overpass);
        var result = await service.GetOrFetchAsync(40.4168, -3.7038);

        result.Should().BeEquivalentTo(freshResult);
        await redis.Received(1).SetAsync(Arg.Any<string>(), Arg.Any<string>(), Arg.Any<TimeSpan>());
    }

    [Fact]
    public async Task GetOrFetchAsync_FetchesFromCellCenter_NotRawRequestCoordinates()
    {
        var redis = Substitute.For<IRedisCacheService>();
        var overpass = Substitute.For<IOverpassClient>();
        redis.GetAsync(Arg.Any<string>()).Returns((string?)null);
        overpass.FetchAsync(Arg.Any<double>(), Arg.Any<double>(), Arg.Any<int>(), Arg.Any<CancellationToken>())
            .Returns(new OverpassResult([], []));

        const double requestLat = 40.4168;
        const double requestLng = -3.7038;
        var expectedGeohash = GeoHash.Encode(requestLat, requestLng, 5);
        var expectedCellCenter = GeoHash.Decode(expectedGeohash).Coordinates;
        expectedCellCenter.Lat.Should().NotBe(requestLat);
        expectedCellCenter.Lon.Should().NotBe(requestLng);

        var service = new GeoRandomCacheService(redis, overpass);
        await service.GetOrFetchAsync(requestLat, requestLng);

        await overpass.Received(1).FetchAsync(
            expectedCellCenter.Lat, expectedCellCenter.Lon, 8500, Arg.Any<CancellationToken>());
    }
}
