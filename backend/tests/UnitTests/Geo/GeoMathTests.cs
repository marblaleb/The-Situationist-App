using FluentAssertions;
using Infrastructure.Geo;
using UnitTests.TestUtils;

namespace UnitTests.Geo;

public class GeoMathTests
{
    [Fact]
    public void DistanceMeters_SamePoint_ReturnsZero()
    {
        GeoMath.DistanceMeters(40.4168, -3.7038, 40.4168, -3.7038)
            .Should().BeApproximately(0, 0.01);
    }

    [Fact]
    public void DistanceMeters_OneDegreeLatitude_IsApproximately111320Meters()
    {
        GeoMath.DistanceMeters(0, 0, 1, 0).Should().BeApproximately(111_320, 200);
    }

    [Fact]
    public void OffsetMeters_ThenDistanceBack_RoundTripsWithinTolerance()
    {
        var (lat, lng) = GeoMath.OffsetMeters(40.4168, -3.7038, dxMeters: 1000, dyMeters: 500);
        var distance = GeoMath.DistanceMeters(40.4168, -3.7038, lat, lng);
        var expected = Math.Sqrt(1000 * 1000 + 500 * 500);
        distance.Should().BeApproximately(expected, 5);
    }

    [Fact]
    public void RandomPointInCircle_AlwaysWithinRadius()
    {
        var random = new SeededRandomSource(7);
        for (var i = 0; i < 500; i++)
        {
            var (lat, lng) = GeoMath.RandomPointInCircle(40.4168, -3.7038, 2000, random);
            GeoMath.DistanceMeters(40.4168, -3.7038, lat, lng)
                .Should().BeLessThanOrEqualTo(2000.5);
        }
    }
}
