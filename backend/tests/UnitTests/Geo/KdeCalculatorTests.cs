using FluentAssertions;
using Infrastructure.Geo;
using NetTopologySuite;
using NetTopologySuite.Geometries;
using UnitTests.TestUtils;

namespace UnitTests.Geo;

public class KdeCalculatorTests
{
    private const double CenterLat = 40.4168;
    private const double CenterLng = -3.7038;
    private const double RadiusMeters = 2000;

    private static List<PoiPoint> ClusteredPois(double lat, double lng, int count, double spreadMeters, int seed)
    {
        var random = new SeededRandomSource(seed);
        var pois = new List<PoiPoint>();
        for (var i = 0; i < count; i++)
        {
            var (pLat, pLng) = GeoMath.RandomPointInCircle(lat, lng, spreadMeters, random);
            pois.Add(new PoiPoint(pLat, pLng));
        }
        return pois;
    }

    [Fact]
    public void Atractor_IsCloserToClusterThanVacio()
    {
        const double clusterLat = 40.4200;
        const double clusterLng = -3.7000;
        var pois = ClusteredPois(clusterLat, clusterLng, count: 200, spreadMeters: 60, seed: 1);
        var calculator = new KdeCalculator(new SeededRandomSource(42));

        var atractor = calculator.SelectPoint(
            CenterLat, CenterLng, RadiusMeters, GeoRandomPointType.Atractor, pois, []);
        var vacio = calculator.SelectPoint(
            CenterLat, CenterLng, RadiusMeters, GeoRandomPointType.Vacio, pois, []);

        var distAtractor = GeoMath.DistanceMeters(atractor.Lat, atractor.Lng, clusterLat, clusterLng);
        var distVacio = GeoMath.DistanceMeters(vacio.Lat, vacio.Lng, clusterLat, clusterLng);

        distAtractor.Should().BeLessThan(distVacio);
    }

    [Fact]
    public void Anomalia_IsCloseToTheExtremeCluster()
    {
        const double clusterLat = 40.4200;
        const double clusterLng = -3.7000;
        var pois = ClusteredPois(clusterLat, clusterLng, count: 200, spreadMeters: 60, seed: 1);
        var calculator = new KdeCalculator(new SeededRandomSource(42));

        var anomalia = calculator.SelectPoint(
            CenterLat, CenterLng, RadiusMeters, GeoRandomPointType.Anomalia, pois, []);

        GeoMath.DistanceMeters(anomalia.Lat, anomalia.Lng, clusterLat, clusterLng)
            .Should().BeLessThan(500);
    }

    [Fact]
    public void NoPois_FallsBackToUniformRandomPoint_WithinRadius()
    {
        var calculator = new KdeCalculator(new SeededRandomSource(42));

        var point = calculator.SelectPoint(
            CenterLat, CenterLng, RadiusMeters, GeoRandomPointType.Atractor, [], []);

        GeoMath.DistanceMeters(CenterLat, CenterLng, point.Lat, point.Lng)
            .Should().BeLessThanOrEqualTo(RadiusMeters + 1);
    }

    [Fact]
    public void ExcludedZone_ResamplesToTheOtherCluster()
    {
        const double clusterALat = 40.4200;
        const double clusterALng = -3.7000;
        const double clusterBLat = 40.4080;
        const double clusterBLng = -3.7120;

        var pois = ClusteredPois(clusterALat, clusterALng, count: 150, spreadMeters: 60, seed: 1)
            .Concat(ClusteredPois(clusterBLat, clusterBLng, count: 150, spreadMeters: 60, seed: 2))
            .ToList();

        var exclusionRing = new ExclusionRing([
            new GeoCoordinate(clusterALat - 0.01, clusterALng - 0.01),
            new GeoCoordinate(clusterALat - 0.01, clusterALng + 0.01),
            new GeoCoordinate(clusterALat + 0.01, clusterALng + 0.01),
            new GeoCoordinate(clusterALat + 0.01, clusterALng - 0.01),
            new GeoCoordinate(clusterALat - 0.01, clusterALng - 0.01),
        ]);

        var calculator = new KdeCalculator(new SeededRandomSource(42));

        var point = calculator.SelectPoint(
            CenterLat, CenterLng, RadiusMeters, GeoRandomPointType.Atractor, pois, [exclusionRing]);

        var distToA = GeoMath.DistanceMeters(point.Lat, point.Lng, clusterALat, clusterALng);
        var distToB = GeoMath.DistanceMeters(point.Lat, point.Lng, clusterBLat, clusterBLng);

        distToB.Should().BeLessThan(distToA);
    }

    [Fact]
    public void FullyExcludedArea_ThrowsNoValidGeoRandomPointException()
    {
        var pois = ClusteredPois(40.4200, -3.7000, count: 200, spreadMeters: 60, seed: 1);
        var exclusionRing = new ExclusionRing([
            new GeoCoordinate(CenterLat - 0.1, CenterLng - 0.1),
            new GeoCoordinate(CenterLat - 0.1, CenterLng + 0.1),
            new GeoCoordinate(CenterLat + 0.1, CenterLng + 0.1),
            new GeoCoordinate(CenterLat + 0.1, CenterLng - 0.1),
            new GeoCoordinate(CenterLat - 0.1, CenterLng - 0.1),
        ]);

        var calculator = new KdeCalculator(new SeededRandomSource(42));

        var act = () => calculator.SelectPoint(
            CenterLat, CenterLng, RadiusMeters, GeoRandomPointType.Atractor, pois, [exclusionRing]);

        act.Should().Throw<NoValidGeoRandomPointException>();
    }

    [Fact]
    public void DownsamplesLargePoiSets_AndStillDiscriminatesDensity()
    {
        const double clusterLat = 40.4200;
        const double clusterLng = -3.7000;
        var pois = ClusteredPois(clusterLat, clusterLng, count: 3500, spreadMeters: 60, seed: 1);
        var calculator = new KdeCalculator(new SeededRandomSource(42));

        var atractor = calculator.SelectPoint(
            CenterLat, CenterLng, RadiusMeters, GeoRandomPointType.Atractor, pois, []);
        var vacio = calculator.SelectPoint(
            CenterLat, CenterLng, RadiusMeters, GeoRandomPointType.Vacio, pois, []);

        var distAtractor = GeoMath.DistanceMeters(atractor.Lat, atractor.Lng, clusterLat, clusterLng);
        var distVacio = GeoMath.DistanceMeters(vacio.Lat, vacio.Lng, clusterLat, clusterLng);

        distAtractor.Should().BeLessThan(distVacio);
    }
}
