# Módulo A — GeoRandom Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship the GeoRandom point generator (Módulo A): a standalone "Explorar" screen where the user picks a radius (500m–5km) and a type (Atractor/Vacío/Anomalía), and the backend returns a single ephemeral point computed via real Gaussian KDE over OpenStreetMap POI density, filtered against a basic OSM safety exclusion list.

**Architecture:** New backend vertical slice `Api/Features/GeoRandom/` (MediatR command + FluentValidation, no persistence) backed by new `Infrastructure/Geo/` components (pure-C# `KdeCalculator`, `OverpassClient` HTTP client, `GeoRandomCacheService` wrapping the existing Redis cache keyed by geohash). New mobile feature `features/georandom/` (BLoC, reused `flutter_map`/theme widgets), reached via a button on `MapPage` that pushes `/home/explore`.

**Tech Stack:** .NET 9, MediatR, FluentValidation, NetTopologySuite (STRtree), NGeoHash, StackExchange.Redis, xUnit + FluentAssertions + NSubstitute; Flutter, flutter_bloc, freezed, Dio, flutter_map, bloc_test + mocktail.

**Spec:** `docs/superpowers/specs/2026-07-28-georandom-design.md`

---

## Known MVP simplification (documented, not a bug)

The Overpass cache key is `georandom:overpass:{geohash-5 of origin}`, but each fetch queries a fixed 5500m radius **around the raw request origin**, not around the geohash cell's center. Two requests that land in the same geohash-5 cell but are several km apart (e.g. near opposite corners of the cell) will each trigger their own Overpass fetch instead of sharing one cache entry. This is a cache-efficiency gap, not a correctness bug — each individual fetch is always large enough (5500m) to fully cover that request's own search radius (max 5000m). Acceptable for MVP; revisit if Overpass load becomes a problem.

---

## Backend

### Task 1: Random source abstraction (CSPRNG)

**Files:**
- Create: `backend/src/Infrastructure/Geo/RandomSource.cs`
- Create: `backend/tests/UnitTests/TestUtils/SeededRandomSource.cs`
- Test: `backend/tests/UnitTests/Geo/RandomSourceTests.cs`

- [ ] **Step 1: Write the failing test**

```csharp
// backend/tests/UnitTests/Geo/RandomSourceTests.cs
using FluentAssertions;
using Infrastructure.Geo;

namespace UnitTests.Geo;

public class RandomSourceTests
{
    [Fact]
    public void NextDouble_ReturnsValuesWithinUnitRange()
    {
        var source = new CryptoRandomSource();
        for (var i = 0; i < 1000; i++)
        {
            var value = source.NextDouble();
            value.Should().BeGreaterThanOrEqualTo(0).And.BeLessThan(1);
        }
    }

    [Fact]
    public void NextDouble_IsNotConstant()
    {
        var source = new CryptoRandomSource();
        var values = Enumerable.Range(0, 20).Select(_ => source.NextDouble()).Distinct().ToList();
        values.Count.Should().BeGreaterThan(1);
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `dotnet test backend/tests/UnitTests --filter "FullyQualifiedName~RandomSourceTests"`
Expected: FAIL (build error — `Infrastructure.Geo.CryptoRandomSource` does not exist)

- [ ] **Step 3: Implement**

```csharp
// backend/src/Infrastructure/Geo/RandomSource.cs
using System.Security.Cryptography;

namespace Infrastructure.Geo;

public interface IRandomSource
{
    double NextDouble();
}

public class CryptoRandomSource : IRandomSource
{
    public double NextDouble()
    {
        Span<byte> bytes = stackalloc byte[8];
        RandomNumberGenerator.Fill(bytes);
        var value = BitConverter.ToUInt64(bytes) >> 11;
        return value / (double)(1UL << 53);
    }
}
```

Also add the seeded test double used by every later test file in this plan:

```csharp
// backend/tests/UnitTests/TestUtils/SeededRandomSource.cs
using Infrastructure.Geo;

namespace UnitTests.TestUtils;

public class SeededRandomSource(int seed) : IRandomSource
{
    private readonly Random _random = new(seed);
    public double NextDouble() => _random.NextDouble();
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `dotnet test backend/tests/UnitTests --filter "FullyQualifiedName~RandomSourceTests"`
Expected: PASS (2 tests)

- [ ] **Step 5: Commit**

```bash
git add backend/src/Infrastructure/Geo/RandomSource.cs backend/tests/UnitTests/TestUtils/SeededRandomSource.cs backend/tests/UnitTests/Geo/RandomSourceTests.cs
git commit -m "feat(georandom): add CSPRNG-backed IRandomSource"
```

---

### Task 2: GeoMath (distance, offset, uniform circle sampling)

**Files:**
- Create: `backend/src/Infrastructure/Geo/GeoMath.cs`
- Test: `backend/tests/UnitTests/Geo/GeoMathTests.cs`

- [ ] **Step 1: Write the failing tests**

```csharp
// backend/tests/UnitTests/Geo/GeoMathTests.cs
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `dotnet test backend/tests/UnitTests --filter "FullyQualifiedName~GeoMathTests"`
Expected: FAIL (build error — `Infrastructure.Geo.GeoMath` does not exist)

- [ ] **Step 3: Implement**

```csharp
// backend/src/Infrastructure/Geo/GeoMath.cs
namespace Infrastructure.Geo;

public static class GeoMath
{
    private const double EarthRadiusMeters = 6_371_000;

    public static double DistanceMeters(double lat1, double lng1, double lat2, double lng2)
    {
        var dLat = ToRadians(lat2 - lat1);
        var dLng = ToRadians(lng2 - lng1);
        var a = Math.Sin(dLat / 2) * Math.Sin(dLat / 2) +
                Math.Cos(ToRadians(lat1)) * Math.Cos(ToRadians(lat2)) *
                Math.Sin(dLng / 2) * Math.Sin(dLng / 2);
        var c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
        return EarthRadiusMeters * c;
    }

    public static (double Lat, double Lng) OffsetMeters(double lat, double lng, double dxMeters, double dyMeters)
    {
        var dLat = dyMeters / EarthRadiusMeters;
        var dLng = dxMeters / (EarthRadiusMeters * Math.Cos(ToRadians(lat)));
        return (lat + ToDegrees(dLat), lng + ToDegrees(dLng));
    }

    public static (double Lat, double Lng) RandomPointInCircle(
        double centerLat, double centerLng, double radiusMeters, IRandomSource random)
    {
        var angle = random.NextDouble() * 2 * Math.PI;
        var r = radiusMeters * Math.Sqrt(random.NextDouble());
        var dx = r * Math.Cos(angle);
        var dy = r * Math.Sin(angle);
        return OffsetMeters(centerLat, centerLng, dx, dy);
    }

    private static double ToRadians(double degrees) => degrees * Math.PI / 180.0;
    private static double ToDegrees(double radians) => radians * 180.0 / Math.PI;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `dotnet test backend/tests/UnitTests --filter "FullyQualifiedName~GeoMathTests"`
Expected: PASS (4 tests)

- [ ] **Step 5: Commit**

```bash
git add backend/src/Infrastructure/Geo/GeoMath.cs backend/tests/UnitTests/Geo/GeoMathTests.cs
git commit -m "feat(georandom): add GeoMath distance/offset/circle-sampling helpers"
```

---

### Task 3: KdeCalculator — core selection algorithm

**Files:**
- Create: `backend/src/Infrastructure/Geo/KdeCalculator.cs`
- Create: `backend/src/Infrastructure/Geo/GeoRandomTypes.cs` (shared `PoiPoint`/`GeoCoordinate`/`ExclusionRing` records)
- Test: `backend/tests/UnitTests/Geo/KdeCalculatorTests.cs`

- [ ] **Step 1: Write the failing tests**

```csharp
// backend/tests/UnitTests/Geo/KdeCalculatorTests.cs
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
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `dotnet test backend/tests/UnitTests --filter "FullyQualifiedName~KdeCalculatorTests"`
Expected: FAIL (build error — `Infrastructure.Geo.KdeCalculator` does not exist)

- [ ] **Step 3: Implement**

```csharp
// backend/src/Infrastructure/Geo/KdeCalculator.cs
using NetTopologySuite;
using NetTopologySuite.Geometries;
using NetTopologySuite.Index.Strtree;

namespace Infrastructure.Geo;

public enum GeoRandomPointType { Atractor, Vacio, Anomalia }

public class NoValidGeoRandomPointException(string message) : Exception(message);

public class KdeCalculator(IRandomSource random)
{
    private const double BandwidthMeters = 120.0;
    private const double CutoffMeters = BandwidthMeters * 3;
    private const int CandidateCount = 3000;
    private const int MaxRetries = 10;
    private const double StdDevEpsilon = 1e-9;

    public (double Lat, double Lng) SelectPoint(
        double centerLat,
        double centerLng,
        double radiusMeters,
        GeoRandomPointType type,
        IReadOnlyList<PoiPoint> pois,
        IReadOnlyList<ExclusionRing> exclusionRings)
    {
        var index = pois.Count > 0 ? BuildIndex(pois) : null;
        var candidates = new List<(double Lat, double Lng, double Density)>(CandidateCount);
        for (var i = 0; i < CandidateCount; i++)
        {
            var (lat, lng) = GeoMath.RandomPointInCircle(centerLat, centerLng, radiusMeters, random);
            var density = index is null ? 0 : ComputeDensity(lat, lng, index);
            candidates.Add((lat, lng, density));
        }

        var densities = candidates.Select(c => c.Density).ToArray();
        var mean = densities.Average();
        var stdDev = Math.Sqrt(densities.Select(d => (d - mean) * (d - mean)).Average());

        var ranked = RankCandidates(candidates, type, mean, stdDev);
        var factory = NtsGeometryServices.Instance.CreateGeometryFactory(4326);
        var exclusionGeometries = exclusionRings.Select(r => BuildPolygon(r, factory)).ToList();

        foreach (var candidate in ranked.Take(MaxRetries))
        {
            var point = factory.CreatePoint(new Coordinate(candidate.Lng, candidate.Lat));
            if (!exclusionGeometries.Any(zone => zone.Covers(point)))
                return (candidate.Lat, candidate.Lng);
        }

        throw new NoValidGeoRandomPointException(
            "No se encontró un candidato válido dentro del radio tras agotar los reintentos.");
    }

    private List<(double Lat, double Lng, double Density)> RankCandidates(
        List<(double Lat, double Lng, double Density)> candidates,
        GeoRandomPointType type,
        double mean,
        double stdDev)
    {
        if (stdDev < StdDevEpsilon)
            return Shuffle(candidates);

        var sortedDensities = candidates.Select(c => c.Density).OrderBy(d => d).ToArray();

        return type switch
        {
            GeoRandomPointType.Atractor => Shuffle(candidates
                .Where(c => c.Density >= Percentile(sortedDensities, 0.90)).ToList()),
            GeoRandomPointType.Vacio => Shuffle(candidates
                .Where(c => c.Density <= Percentile(sortedDensities, 0.10)).ToList()),
            GeoRandomPointType.Anomalia => candidates
                .OrderByDescending(c => Math.Abs((c.Density - mean) / stdDev)).ToList(),
            _ => throw new ArgumentOutOfRangeException(nameof(type)),
        };
    }

    private List<(double Lat, double Lng, double Density)> Shuffle(
        List<(double Lat, double Lng, double Density)> items)
    {
        var array = items.ToArray();
        for (var i = array.Length - 1; i > 0; i--)
        {
            var j = (int)(random.NextDouble() * (i + 1));
            (array[i], array[j]) = (array[j], array[i]);
        }
        return array.ToList();
    }

    private static double Percentile(double[] sortedValues, double p)
    {
        if (sortedValues.Length == 0) return 0;
        var index = (int)Math.Round(p * (sortedValues.Length - 1));
        return sortedValues[index];
    }

    private static STRtree<PoiPoint> BuildIndex(IReadOnlyList<PoiPoint> pois)
    {
        var tree = new STRtree<PoiPoint>();
        foreach (var poi in pois)
            tree.Insert(new Envelope(poi.Lng, poi.Lng, poi.Lat, poi.Lat), poi);
        return tree;
    }

    private static double ComputeDensity(double lat, double lng, STRtree<PoiPoint> index)
    {
        var cutoffDegreesLat = CutoffMeters / 111_320.0;
        var cutoffDegreesLng = cutoffDegreesLat / Math.Cos(lat * Math.PI / 180.0);
        var envelope = new Envelope(
            lng - cutoffDegreesLng, lng + cutoffDegreesLng,
            lat - cutoffDegreesLat, lat + cutoffDegreesLat);

        double density = 0;
        foreach (var poi in index.Query(envelope))
        {
            var distance = GeoMath.DistanceMeters(lat, lng, poi.Lat, poi.Lng);
            if (distance <= CutoffMeters)
                density += Math.Exp(-(distance * distance) / (2 * BandwidthMeters * BandwidthMeters));
        }
        return density;
    }

    private static Geometry BuildPolygon(ExclusionRing ring, GeometryFactory factory)
    {
        var coords = ring.Points.Select(p => new Coordinate(p.Lng, p.Lat)).ToList();
        if (coords.Count > 0 && !coords[0].Equals2D(coords[^1]))
            coords.Add(coords[0]);
        return factory.CreatePolygon(coords.ToArray());
    }
}
```

This references `PoiPoint`, `GeoCoordinate`, `ExclusionRing` — these are defined in Task 4 (`OverpassClient.cs`). Add this minimal placeholder file first so `KdeCalculator.cs` compiles independently:

```csharp
// backend/src/Infrastructure/Geo/GeoRandomTypes.cs
namespace Infrastructure.Geo;

public record PoiPoint(double Lat, double Lng);
public record GeoCoordinate(double Lat, double Lng);
public record ExclusionRing(IReadOnlyList<GeoCoordinate> Points);
```

- [ ] **Step 4: Run test to verify it passes**

Run: `dotnet test backend/tests/UnitTests --filter "FullyQualifiedName~KdeCalculatorTests"`
Expected: PASS (5 tests)

- [ ] **Step 5: Commit**

```bash
git add backend/src/Infrastructure/Geo/KdeCalculator.cs backend/src/Infrastructure/Geo/GeoRandomTypes.cs backend/tests/UnitTests/Geo/KdeCalculatorTests.cs
git commit -m "feat(georandom): add KdeCalculator with gaussian KDE, percentile selection, safety-filter retries"
```

---

### Task 4: OverpassClient

**Files:**
- Create: `backend/src/Infrastructure/Geo/OverpassClient.cs`
- Modify: `backend/src/Infrastructure/Geo/GeoRandomTypes.cs` (add `OverpassResult`)
- Test: `backend/tests/UnitTests/Geo/OverpassClientTests.cs`

- [ ] **Step 1: Write the failing tests**

```csharp
// backend/tests/UnitTests/Geo/OverpassClientTests.cs
using System.Net;
using System.Text;
using FluentAssertions;
using Infrastructure.Geo;

namespace UnitTests.Geo;

public class OverpassClientTests
{
    private static HttpClient CreateClient(string poisJson, string exclusionsJson)
    {
        var handler = new FakeHttpMessageHandler(poisJson, exclusionsJson);
        return new HttpClient(handler) { BaseAddress = new Uri("https://overpass-api.de/api/") };
    }

    [Fact]
    public async Task FetchAsync_ParsesPoisFromNodesAndWayCenters()
    {
        const string poisJson = """
        {
          "elements": [
            { "type": "node", "lat": 40.42, "lon": -3.70, "tags": { "shop": "bakery" } },
            { "type": "way", "center": { "lat": 40.421, "lon": -3.701 }, "tags": { "building": "yes" } }
          ]
        }
        """;
        const string exclusionsJson = """{ "elements": [] }""";

        var client = new OverpassClient(CreateClient(poisJson, exclusionsJson));
        var result = await client.FetchAsync(40.4168, -3.7038, 2000);

        result.Pois.Should().HaveCount(2);
        result.Pois.Should().ContainEquivalentOf(new PoiPoint(40.42, -3.70));
        result.Pois.Should().ContainEquivalentOf(new PoiPoint(40.421, -3.701));
    }

    [Fact]
    public async Task FetchAsync_ParsesExclusionRingsFromWayGeometry()
    {
        const string poisJson = """{ "elements": [] }""";
        const string exclusionsJson = """
        {
          "elements": [
            {
              "type": "way",
              "tags": { "natural": "water" },
              "geometry": [
                { "lat": 40.40, "lon": -3.70 },
                { "lat": 40.41, "lon": -3.70 },
                { "lat": 40.41, "lon": -3.71 },
                { "lat": 40.40, "lon": -3.71 },
                { "lat": 40.40, "lon": -3.70 }
              ]
            }
          ]
        }
        """;

        var client = new OverpassClient(CreateClient(poisJson, exclusionsJson));
        var result = await client.FetchAsync(40.4168, -3.7038, 2000);

        result.ExclusionRings.Should().HaveCount(1);
        result.ExclusionRings[0].Points.Should().HaveCount(5);
        result.ExclusionRings[0].Points[0].Should().Be(new GeoCoordinate(40.40, -3.70));
    }

    [Fact]
    public async Task FetchAsync_Throws_WhenOverpassReturnsError()
    {
        var handler = new FailingHttpMessageHandler();
        var client = new OverpassClient(new HttpClient(handler) { BaseAddress = new Uri("https://overpass-api.de/api/") });

        var act = () => client.FetchAsync(40.4168, -3.7038, 2000);

        await act.Should().ThrowAsync<HttpRequestException>();
    }
}

file class FakeHttpMessageHandler(string poisResponse, string exclusionsResponse) : HttpMessageHandler
{
    private int _callCount;

    protected override Task<HttpResponseMessage> SendAsync(
        HttpRequestMessage request, CancellationToken cancellationToken)
    {
        _callCount++;
        var body = _callCount == 1 ? poisResponse : exclusionsResponse;
        var response = new HttpResponseMessage(HttpStatusCode.OK)
        {
            Content = new StringContent(body, Encoding.UTF8, "application/json"),
        };
        return Task.FromResult(response);
    }
}

file class FailingHttpMessageHandler : HttpMessageHandler
{
    protected override Task<HttpResponseMessage> SendAsync(
        HttpRequestMessage request, CancellationToken cancellationToken)
        => Task.FromResult(new HttpResponseMessage(HttpStatusCode.ServiceUnavailable));
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `dotnet test backend/tests/UnitTests --filter "FullyQualifiedName~OverpassClientTests"`
Expected: FAIL (build error — `Infrastructure.Geo.OverpassClient` does not exist)

- [ ] **Step 3: Implement**

Add `OverpassResult` to the shared types file:

```csharp
// backend/src/Infrastructure/Geo/GeoRandomTypes.cs (append)
public record OverpassResult(IReadOnlyList<PoiPoint> Pois, IReadOnlyList<ExclusionRing> ExclusionRings);
```

```csharp
// backend/src/Infrastructure/Geo/OverpassClient.cs
using System.Text.Json;

namespace Infrastructure.Geo;

public interface IOverpassClient
{
    Task<OverpassResult> FetchAsync(double lat, double lng, int radiusMeters, CancellationToken ct = default);
}

public class OverpassClient(HttpClient httpClient) : IOverpassClient
{
    private static readonly JsonSerializerOptions JsonOptions = new(JsonSerializerDefaults.Web);

    public async Task<OverpassResult> FetchAsync(double lat, double lng, int radiusMeters, CancellationToken ct = default)
    {
        var pois = await FetchPoisAsync(lat, lng, radiusMeters, ct);
        var exclusions = await FetchExclusionsAsync(lat, lng, radiusMeters, ct);
        return new OverpassResult(pois, exclusions);
    }

    private async Task<IReadOnlyList<PoiPoint>> FetchPoisAsync(double lat, double lng, int radiusMeters, CancellationToken ct)
    {
        var query = $$"""
        [out:json][timeout:25];
        (
          node["shop"](around:{{radiusMeters}},{{lat}},{{lng}});
          node["amenity"](around:{{radiusMeters}},{{lat}},{{lng}});
          way["building"](around:{{radiusMeters}},{{lat}},{{lng}});
        );
        out center;
        """;

        var response = await SendQueryAsync(query, ct);
        var pois = new List<PoiPoint>();
        foreach (var element in response.Elements)
        {
            if (element.Type == "node" && element.Lat is not null && element.Lon is not null)
                pois.Add(new PoiPoint(element.Lat.Value, element.Lon.Value));
            else if (element.Type == "way" && element.Center is not null)
                pois.Add(new PoiPoint(element.Center.Lat, element.Center.Lon));
        }
        return pois;
    }

    private async Task<IReadOnlyList<ExclusionRing>> FetchExclusionsAsync(double lat, double lng, int radiusMeters, CancellationToken ct)
    {
        var query = $$"""
        [out:json][timeout:25];
        (
          way["natural"="water"](around:{{radiusMeters}},{{lat}},{{lng}});
          way["landuse"="military"](around:{{radiusMeters}},{{lat}},{{lng}});
          way["leisure"="nature_reserve"](around:{{radiusMeters}},{{lat}},{{lng}});
          way["boundary"="protected_area"](around:{{radiusMeters}},{{lat}},{{lng}});
          way["building"]["access"~"^(private|no)$"](around:{{radiusMeters}},{{lat}},{{lng}});
        );
        out geom;
        """;

        var response = await SendQueryAsync(query, ct);
        var rings = new List<ExclusionRing>();
        foreach (var element in response.Elements)
        {
            if (element.Type != "way" || element.Geometry is null || element.Geometry.Count < 3)
                continue;
            var points = element.Geometry.Select(g => new GeoCoordinate(g.Lat, g.Lon)).ToList();
            rings.Add(new ExclusionRing(points));
        }
        return rings;
    }

    private async Task<OverpassResponse> SendQueryAsync(string query, CancellationToken ct)
    {
        var content = new FormUrlEncodedContent(new Dictionary<string, string> { ["data"] = query });
        var httpResponse = await httpClient.PostAsync("interpreter", content, ct);
        if (!httpResponse.IsSuccessStatusCode)
            throw new HttpRequestException($"Overpass API {(int)httpResponse.StatusCode}");

        var stream = await httpResponse.Content.ReadAsStreamAsync(ct);
        var result = await JsonSerializer.DeserializeAsync<OverpassResponse>(stream, JsonOptions, ct);
        return result ?? new OverpassResponse([]);
    }

    private record OverpassResponse(List<OverpassElement> Elements);
    private record OverpassElement(
        string Type,
        double? Lat,
        double? Lon,
        OverpassCenter? Center,
        List<OverpassGeometryPoint>? Geometry);
    private record OverpassCenter(double Lat, double Lon);
    private record OverpassGeometryPoint(double Lat, double Lon);
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `dotnet test backend/tests/UnitTests --filter "FullyQualifiedName~OverpassClientTests"`
Expected: PASS (3 tests)

- [ ] **Step 5: Commit**

```bash
git add backend/src/Infrastructure/Geo/OverpassClient.cs backend/src/Infrastructure/Geo/GeoRandomTypes.cs backend/tests/UnitTests/Geo/OverpassClientTests.cs
git commit -m "feat(georandom): add OverpassClient for POI density and safety-exclusion queries"
```

---

### Task 5: GeoRandomCacheService (Redis + geohash)

**Files:**
- Create: `backend/src/Infrastructure/Geo/GeoRandomCacheService.cs`
- Test: `backend/tests/UnitTests/Geo/GeoRandomCacheServiceTests.cs`

- [ ] **Step 1: Write the failing tests**

```csharp
// backend/tests/UnitTests/Geo/GeoRandomCacheServiceTests.cs
using System.Text.Json;
using FluentAssertions;
using Infrastructure.Cache;
using Infrastructure.Geo;
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
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `dotnet test backend/tests/UnitTests --filter "FullyQualifiedName~GeoRandomCacheServiceTests"`
Expected: FAIL (build error — `Infrastructure.Geo.GeoRandomCacheService` does not exist)

- [ ] **Step 3: Implement**

```csharp
// backend/src/Infrastructure/Geo/GeoRandomCacheService.cs
using System.Text.Json;
using Infrastructure.Cache;
using NGeoHash;

namespace Infrastructure.Geo;

public interface IGeoRandomCacheService
{
    Task<OverpassResult> GetOrFetchAsync(double lat, double lng, CancellationToken ct = default);
}

public class GeoRandomCacheService(IRedisCacheService cache, IOverpassClient overpass) : IGeoRandomCacheService
{
    private const int FetchRadiusMeters = 5500;
    private static readonly TimeSpan CacheTtl = TimeSpan.FromDays(7);
    private static readonly JsonSerializerOptions JsonOptions = new(JsonSerializerDefaults.Web);

    public async Task<OverpassResult> GetOrFetchAsync(double lat, double lng, CancellationToken ct = default)
    {
        var key = $"georandom:overpass:{GeoHash.Encode(lat, lng, 5)}";
        var cached = await cache.GetAsync(key);
        if (cached is not null)
            return JsonSerializer.Deserialize<OverpassResult>(cached, JsonOptions)!;

        var result = await overpass.FetchAsync(lat, lng, FetchRadiusMeters, ct);
        await cache.SetAsync(key, JsonSerializer.Serialize(result, JsonOptions), CacheTtl);
        return result;
    }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `dotnet test backend/tests/UnitTests --filter "FullyQualifiedName~GeoRandomCacheServiceTests"`
Expected: PASS (2 tests)

- [ ] **Step 5: Commit**

```bash
git add backend/src/Infrastructure/Geo/GeoRandomCacheService.cs backend/tests/UnitTests/Geo/GeoRandomCacheServiceTests.cs
git commit -m "feat(georandom): add Redis geohash cache for Overpass results"
```

---

### Task 6: GenerateGeoRandomPointCommand (validator + handler)

**Files:**
- Create: `backend/src/Api/Features/GeoRandom/GeoRandomModels.cs`
- Create: `backend/src/Api/Features/GeoRandom/GenerateGeoRandomPointCommand.cs`
- Test: `backend/tests/UnitTests/Validators/GenerateGeoRandomPointCommandValidatorTests.cs`
- Test: `backend/tests/UnitTests/Handlers/GenerateGeoRandomPointCommandHandlerTests.cs`

- [ ] **Step 1: Write the failing tests**

```csharp
// backend/tests/UnitTests/Validators/GenerateGeoRandomPointCommandValidatorTests.cs
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
```

```csharp
// backend/tests/UnitTests/Handlers/GenerateGeoRandomPointCommandHandlerTests.cs
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
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `dotnet test backend/tests/UnitTests --filter "FullyQualifiedName~GenerateGeoRandomPointCommand"`
Expected: FAIL (build error — `Api.Features.GeoRandom` types do not exist)

- [ ] **Step 3: Implement**

```csharp
// backend/src/Api/Features/GeoRandom/GeoRandomModels.cs
namespace Api.Features.GeoRandom;

public record GenerateGeoRandomPointRequest(double Latitude, double Longitude, int RadiusMeters, string Type);

public record GeoRandomPointResponse(double Lat, double Lng, string Type, DateTimeOffset GeneratedAt);
```

```csharp
// backend/src/Api/Features/GeoRandom/GenerateGeoRandomPointCommand.cs
using FluentValidation;
using Infrastructure.Cache;
using Infrastructure.Geo;
using MediatR;

namespace Api.Features.GeoRandom;

public record GenerateGeoRandomPointCommand(Guid UserId, GenerateGeoRandomPointRequest Request)
    : IRequest<GeoRandomPointResponse>;

public class GenerateGeoRandomPointCommandValidator : AbstractValidator<GenerateGeoRandomPointCommand>
{
    public GenerateGeoRandomPointCommandValidator()
    {
        RuleFor(x => x.Request.Type)
            .Must(t => Enum.TryParse<GeoRandomPointType>(t, ignoreCase: true, out _))
            .WithMessage("Invalid type. Valid values: Atractor, Vacio, Anomalia");
        RuleFor(x => x.Request.Latitude).InclusiveBetween(-90, 90);
        RuleFor(x => x.Request.Longitude).InclusiveBetween(-180, 180);
        RuleFor(x => x.Request.RadiusMeters).InclusiveBetween(500, 5000);
    }
}

public class RateLimitExceededException : Exception;

public class GeoDataUnavailableException(string message) : Exception(message);

public class GenerateGeoRandomPointCommandHandler(
    IGeoRandomCacheService cache,
    KdeCalculator kde,
    IRedisCacheService throttle) : IRequestHandler<GenerateGeoRandomPointCommand, GeoRandomPointResponse>
{
    private static readonly TimeSpan ThrottleWindow = TimeSpan.FromSeconds(4);

    public async Task<GeoRandomPointResponse> Handle(GenerateGeoRandomPointCommand request, CancellationToken ct)
    {
        var throttleKey = $"georandom:throttle:{request.UserId}";
        if (await throttle.ExistsAsync(throttleKey))
            throw new RateLimitExceededException();
        await throttle.SetAsync(throttleKey, "1", ThrottleWindow);

        OverpassResult data;
        try
        {
            data = await cache.GetOrFetchAsync(request.Request.Latitude, request.Request.Longitude, ct);
        }
        catch (HttpRequestException)
        {
            throw new GeoDataUnavailableException(
                "No pudimos generar un punto ahora, intentá de nuevo en unos minutos.");
        }

        var type = Enum.Parse<GeoRandomPointType>(request.Request.Type, ignoreCase: true);
        var (lat, lng) = kde.SelectPoint(
            request.Request.Latitude,
            request.Request.Longitude,
            request.Request.RadiusMeters,
            type,
            data.Pois,
            data.ExclusionRings);

        return new GeoRandomPointResponse(lat, lng, type.ToString(), DateTimeOffset.UtcNow);
    }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `dotnet test backend/tests/UnitTests --filter "FullyQualifiedName~GenerateGeoRandomPointCommand"`
Expected: PASS (11 tests: 8 validator + 3 handler)

- [ ] **Step 5: Commit**

```bash
git add backend/src/Api/Features/GeoRandom/ backend/tests/UnitTests/Validators/GenerateGeoRandomPointCommandValidatorTests.cs backend/tests/UnitTests/Handlers/GenerateGeoRandomPointCommandHandlerTests.cs
git commit -m "feat(georandom): add GenerateGeoRandomPointCommand with validation and throttling"
```

---

### Task 7: Endpoint + DI wiring + config

**Files:**
- Create: `backend/src/Api/Features/GeoRandom/GeoRandomEndpoints.cs`
- Modify: `backend/src/Infrastructure/InfrastructureExtensions.cs`
- Modify: `backend/src/Api/Program.cs`
- Modify: `backend/src/Api/appsettings.json`

- [ ] **Step 1: Add the endpoint**

```csharp
// backend/src/Api/Features/GeoRandom/GeoRandomEndpoints.cs
using Infrastructure.Geo;
using MediatR;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace Api.Features.GeoRandom;

public static class GeoRandomEndpoints
{
    public static IEndpointRouteBuilder MapGeoRandomEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/georandom").RequireAuthorization();

        group.MapPost("/generate", async (
            GenerateGeoRandomPointRequest req,
            ClaimsPrincipal principal,
            ISender mediator) =>
        {
            var userId = Guid.Parse(principal.FindFirstValue(JwtRegisteredClaimNames.Sub)!);
            try
            {
                var result = await mediator.Send(new GenerateGeoRandomPointCommand(userId, req));
                return Results.Ok(result);
            }
            catch (RateLimitExceededException)
            {
                return Results.Json(
                    new { error = "límite alcanzado, esperá unos segundos" },
                    statusCode: StatusCodes.Status429TooManyRequests);
            }
            catch (GeoDataUnavailableException ex)
            {
                return Results.Json(
                    new { error = ex.Message },
                    statusCode: StatusCodes.Status503ServiceUnavailable);
            }
            catch (NoValidGeoRandomPointException)
            {
                return Results.UnprocessableEntity(
                    new { error = "no encontramos una zona válida con este radio, probá un radio mayor" });
            }
        });

        return app;
    }
}
```

- [ ] **Step 2: Register services in `InfrastructureExtensions.cs`**

Add `using Infrastructure.Geo;` at the top, and inside `AddInfrastructure`, right after the `LocalContentService` registration:

```csharp
        // GeoRandom (Módulo A) — Overpass client, geohash cache, KDE calculator
        services.AddHttpClient<IOverpassClient, OverpassClient>(client =>
        {
            client.BaseAddress = new Uri(config["Overpass:BaseUrl"] ?? "https://overpass-api.de/api/");
            client.Timeout = TimeSpan.FromSeconds(30);
        });
        services.AddScoped<IGeoRandomCacheService, GeoRandomCacheService>();
        services.AddSingleton<IRandomSource, CryptoRandomSource>();
        services.AddSingleton<KdeCalculator>();
```

- [ ] **Step 3: Wire the endpoint into `Program.cs`**

Add `using Api.Features.GeoRandom;` near the other `using Api.Features.*` lines, and add this line after `app.MapUserEndpoints();`:

```csharp
app.MapGeoRandomEndpoints();
```

- [ ] **Step 4: Add config to `appsettings.json`**

Add this block after `"SignalR"`:

```json
  "Overpass": {
    "BaseUrl": "https://overpass-api.de/api/"
  },
```

- [ ] **Step 5: Verify the whole backend builds and all tests still pass**

Run: `dotnet build backend/src/Api`
Expected: Build succeeded, 0 errors

Run: `dotnet test backend/tests/UnitTests`
Expected: PASS (all tests, including the pre-existing ones)

- [ ] **Step 6: Commit**

```bash
git add backend/src/Api/Features/GeoRandom/GeoRandomEndpoints.cs backend/src/Infrastructure/InfrastructureExtensions.cs backend/src/Api/Program.cs backend/src/Api/appsettings.json
git commit -m "feat(georandom): wire POST /georandom/generate endpoint and DI registration"
```

---

## Mobile

### Task 8: GeoRandomPointModel

**Files:**
- Create: `mobile/lib/shared/models/georandom_point_model.dart`

- [ ] **Step 1: Write the model**

```dart
// mobile/lib/shared/models/georandom_point_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'georandom_point_model.freezed.dart';
part 'georandom_point_model.g.dart';

@freezed
class GeoRandomPointModel with _$GeoRandomPointModel {
  const factory GeoRandomPointModel({
    required double lat,
    required double lng,
    required String type,
    required DateTime generatedAt,
  }) = _GeoRandomPointModel;

  factory GeoRandomPointModel.fromJson(Map<String, dynamic> json) =>
      _$GeoRandomPointModelFromJson(json);
}
```

- [ ] **Step 2: Generate the freezed/json_serializable code**

Run (from `mobile/`): `dart run build_runner build --delete-conflicting-outputs`
Expected: `georandom_point_model.freezed.dart` and `georandom_point_model.g.dart` are generated alongside the model, build succeeds with no conflicts.

- [ ] **Step 3: Commit**

```bash
git add mobile/lib/shared/models/georandom_point_model.dart mobile/lib/shared/models/georandom_point_model.freezed.dart mobile/lib/shared/models/georandom_point_model.g.dart
git commit -m "feat(georandom): add GeoRandomPointModel"
```

---

### Task 9: LocationService — explicit permission check

**Files:**
- Modify: `mobile/lib/core/location/location_service.dart`

- [ ] **Step 1: Add the permission-check method**

Add this enum above the class, and this method inside `LocationService` (leave `getCurrentPosition` and `positionStream` untouched — other features rely on their current fallback behavior):

```dart
enum LocationPermissionStatus { granted, denied, deniedForever, serviceDisabled }

// inside class LocationService:
  Future<LocationPermissionStatus> ensureLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return LocationPermissionStatus.serviceDisabled;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionStatus.deniedForever;
    }
    if (permission == LocationPermission.denied) {
      return LocationPermissionStatus.denied;
    }
    return LocationPermissionStatus.granted;
  }
```

- [ ] **Step 2: Verify it compiles**

Run: `cd mobile && flutter analyze lib/core/location/location_service.dart`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add mobile/lib/core/location/location_service.dart
git commit -m "feat(georandom): add explicit LocationService.ensureLocationPermission()"
```

---

### Task 10: GeoRandom repository

**Files:**
- Create: `mobile/lib/features/georandom/data/i_georandom_repository.dart`
- Create: `mobile/lib/features/georandom/data/georandom_repository.dart`

- [ ] **Step 1: Write the interface and implementation**

```dart
// mobile/lib/features/georandom/data/i_georandom_repository.dart
import '../../../shared/models/georandom_point_model.dart';

abstract class IGeoRandomRepository {
  Future<GeoRandomPointModel> generate({
    required double lat,
    required double lng,
    required int radiusMeters,
    required String type,
  });
}
```

```dart
// mobile/lib/features/georandom/data/georandom_repository.dart
import '../../../core/network/api_client.dart';
import '../../../shared/models/georandom_point_model.dart';
import 'i_georandom_repository.dart';

class GeoRandomRepository implements IGeoRandomRepository {
  final ApiClient _client;

  GeoRandomRepository(this._client);

  @override
  Future<GeoRandomPointModel> generate({
    required double lat,
    required double lng,
    required int radiusMeters,
    required String type,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/georandom/generate',
      data: {
        'latitude': lat,
        'longitude': lng,
        'radiusMeters': radiusMeters,
        'type': type,
      },
    );
    return GeoRandomPointModel.fromJson(response.data!);
  }
}
```

- [ ] **Step 2: Verify it compiles**

Run: `cd mobile && flutter analyze lib/features/georandom`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add mobile/lib/features/georandom/data/
git commit -m "feat(georandom): add GeoRandomRepository"
```

---

### Task 11: GeoRandomBloc

**Files:**
- Create: `mobile/lib/features/georandom/bloc/georandom_bloc.dart`
- Test: `mobile/test/features/georandom/georandom_bloc_test.dart`

- [ ] **Step 1: Write the failing tests**

```dart
// mobile/test/features/georandom/georandom_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:situationist/core/location/location_service.dart';
import 'package:situationist/features/georandom/bloc/georandom_bloc.dart';
import 'package:situationist/features/georandom/data/i_georandom_repository.dart';
import 'package:situationist/shared/models/georandom_point_model.dart';

class MockGeoRandomRepository extends Mock implements IGeoRandomRepository {}
class MockLocationService extends Mock implements LocationService {}

final _mockPoint = GeoRandomPointModel(
  lat: 40.42,
  lng: -3.70,
  type: 'Atractor',
  generatedAt: DateTime.now(),
);

void main() {
  late MockGeoRandomRepository repo;
  late MockLocationService location;

  setUp(() {
    repo = MockGeoRandomRepository();
    location = MockLocationService();
  });

  group('GeoRandomBloc', () {
    blocTest<GeoRandomBloc, GeoRandomState>(
      'emite GeoRandomSuccess al generar exitosamente con permiso otorgado',
      build: () {
        when(() => location.ensureLocationPermission())
            .thenAnswer((_) async => LocationPermissionStatus.granted);
        when(() => location.getCurrentPosition())
            .thenAnswer((_) async => (40.4168, -3.7038));
        when(() => repo.generate(
              lat: any(named: 'lat'),
              lng: any(named: 'lng'),
              radiusMeters: any(named: 'radiusMeters'),
              type: any(named: 'type'),
            )).thenAnswer((_) async => _mockPoint);
        return GeoRandomBloc(repository: repo, locationService: location);
      },
      act: (bloc) => bloc.add(GeoRandomGenerateRequested(radiusMeters: 2000, type: 'Atractor')),
      expect: () => [
        isA<GeoRandomLoading>(),
        isA<GeoRandomSuccess>(),
      ],
    );

    blocTest<GeoRandomBloc, GeoRandomState>(
      'emite GeoRandomPermissionRequired cuando no hay permiso de ubicación',
      build: () {
        when(() => location.ensureLocationPermission())
            .thenAnswer((_) async => LocationPermissionStatus.denied);
        return GeoRandomBloc(repository: repo, locationService: location);
      },
      act: (bloc) => bloc.add(GeoRandomGenerateRequested(radiusMeters: 2000, type: 'Atractor')),
      expect: () => [
        isA<GeoRandomLoading>(),
        isA<GeoRandomPermissionRequired>(),
      ],
    );

    blocTest<GeoRandomBloc, GeoRandomState>(
      'emite GeoRandomError cuando el repositorio falla',
      build: () {
        when(() => location.ensureLocationPermission())
            .thenAnswer((_) async => LocationPermissionStatus.granted);
        when(() => location.getCurrentPosition())
            .thenAnswer((_) async => (40.4168, -3.7038));
        when(() => repo.generate(
              lat: any(named: 'lat'),
              lng: any(named: 'lng'),
              radiusMeters: any(named: 'radiusMeters'),
              type: any(named: 'type'),
            )).thenThrow(Exception('503'));
        return GeoRandomBloc(repository: repo, locationService: location);
      },
      act: (bloc) => bloc.add(GeoRandomGenerateRequested(radiusMeters: 2000, type: 'Atractor')),
      expect: () => [
        isA<GeoRandomLoading>(),
        isA<GeoRandomError>(),
      ],
    );
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd mobile && flutter test test/features/georandom/georandom_bloc_test.dart`
Expected: FAIL (compile error — `situationist/features/georandom/bloc/georandom_bloc.dart` does not exist)

- [ ] **Step 3: Implement**

```dart
// mobile/lib/features/georandom/bloc/georandom_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/location/location_service.dart';
import '../../../shared/models/georandom_point_model.dart';
import '../data/i_georandom_repository.dart';

// Events
abstract class GeoRandomEvent extends Equatable {}

class GeoRandomGenerateRequested extends GeoRandomEvent {
  final int radiusMeters;
  final String type;

  GeoRandomGenerateRequested({required this.radiusMeters, required this.type});

  @override
  List<Object?> get props => [radiusMeters, type];
}

// States
abstract class GeoRandomState extends Equatable {}

class GeoRandomIdle extends GeoRandomState {
  @override
  List<Object?> get props => [];
}

class GeoRandomLoading extends GeoRandomState {
  @override
  List<Object?> get props => [];
}

class GeoRandomSuccess extends GeoRandomState {
  final GeoRandomPointModel point;
  GeoRandomSuccess(this.point);
  @override
  List<Object?> get props => [point];
}

class GeoRandomPermissionRequired extends GeoRandomState {
  @override
  List<Object?> get props => [];
}

class GeoRandomError extends GeoRandomState {
  final String message;
  GeoRandomError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class GeoRandomBloc extends Bloc<GeoRandomEvent, GeoRandomState> {
  final IGeoRandomRepository _repository;
  final LocationService _locationService;

  GeoRandomBloc({
    required IGeoRandomRepository repository,
    required LocationService locationService,
  })  : _repository = repository,
        _locationService = locationService,
        super(GeoRandomIdle()) {
    on<GeoRandomGenerateRequested>(_onGenerateRequested);
  }

  Future<void> _onGenerateRequested(
    GeoRandomGenerateRequested event,
    Emitter<GeoRandomState> emit,
  ) async {
    emit(GeoRandomLoading());

    final permission = await _locationService.ensureLocationPermission();
    if (permission != LocationPermissionStatus.granted) {
      emit(GeoRandomPermissionRequired());
      return;
    }

    try {
      final (lat, lng) = await _locationService.getCurrentPosition();
      final point = await _repository.generate(
        lat: lat,
        lng: lng,
        radiusMeters: event.radiusMeters,
        type: event.type,
      );
      emit(GeoRandomSuccess(point));
    } catch (e) {
      emit(GeoRandomError(e.toString()));
    }
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd mobile && flutter test test/features/georandom/georandom_bloc_test.dart`
Expected: PASS (3 tests)

- [ ] **Step 5: Commit**

```bash
git add mobile/lib/features/georandom/bloc/ mobile/test/features/georandom/
git commit -m "feat(georandom): add GeoRandomBloc with permission-gated generation flow"
```

---

### Task 12: GeoRandomPage UI

**Files:**
- Create: `mobile/lib/features/georandom/pages/georandom_page.dart`

- [ ] **Step 1: Implement the page**

```dart
// mobile/lib/features/georandom/pages/georandom_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mono_text.dart';
import '../../../core/widgets/void_button.dart';
import '../bloc/georandom_bloc.dart';

class GeoRandomPage extends StatefulWidget {
  const GeoRandomPage({super.key});

  @override
  State<GeoRandomPage> createState() => _GeoRandomPageState();
}

class _GeoRandomPageState extends State<GeoRandomPage> {
  double _radiusMeters = 2000;
  String _selectedType = 'Atractor';

  static const _types = {
    'Atractor': 'zona de alta densidad',
    'Vacio': 'zona de baja densidad',
    'Anomalia': 'punto estadísticamente extremo',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgVoid,
      body: SafeArea(
        child: BlocBuilder<GeoRandomBloc, GeoRandomState>(
          builder: (context, state) {
            void onGenerate() => context.read<GeoRandomBloc>().add(
                  GeoRandomGenerateRequested(
                    radiusMeters: _radiusMeters.round(),
                    type: _selectedType,
                  ),
                );

            if (state is GeoRandomSuccess) {
              return _ResultView(state: state, onGenerateAgain: onGenerate);
            }
            return _FormView(
              radiusMeters: _radiusMeters,
              selectedType: _selectedType,
              types: _types,
              state: state,
              onRadiusChanged: (v) => setState(() => _radiusMeters = v),
              onTypeChanged: (t) => setState(() => _selectedType = t),
              onGenerate: onGenerate,
            );
          },
        ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  final double radiusMeters;
  final String selectedType;
  final Map<String, String> types;
  final GeoRandomState state;
  final ValueChanged<double> onRadiusChanged;
  final ValueChanged<String> onTypeChanged;
  final VoidCallback onGenerate;

  const _FormView({
    required this.radiusMeters,
    required this.selectedType,
    required this.types,
    required this.state,
    required this.onRadiusChanged,
    required this.onTypeChanged,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Text(
              '← VOLVER',
              style: TextStyle(
                color: AppColors.fgMuted,
                fontFamily: 'JetBrainsMono',
                fontSize: 11,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('EXPLORAR', style: AppTextStyles.monoDisplay),
          const SizedBox(height: 4),
          Container(height: 1, color: AppColors.fgMuted),
          const SizedBox(height: 24),
          MonoText(
            'RADIO: ${(radiusMeters / 1000).toStringAsFixed(1)} km',
            color: AppColors.fgPrimary,
          ),
          Slider(
            value: radiusMeters,
            min: 500,
            max: 5000,
            divisions: 45,
            activeColor: AppColors.phosphor,
            onChanged: onRadiusChanged,
          ),
          const SizedBox(height: 16),
          ...types.entries.map((e) => _TypeRow(
                type: e.key,
                description: e.value,
                selected: selectedType == e.key,
                onTap: () => onTypeChanged(e.key),
              )),
          const SizedBox(height: 24),
          if (state is GeoRandomPermissionRequired)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: MonoText(
                'necesitamos tu ubicación para generar un punto cerca tuyo. activá el permiso e intentá de nuevo.',
                color: AppColors.fgSecondary,
              ),
            ),
          if (state is GeoRandomError)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MonoText(
                (state as GeoRandomError).message,
                color: AppColors.fgSecondary,
              ),
            ),
          VoidButton(
            label: 'GENERAR',
            onPressed: state is GeoRandomLoading ? null : onGenerate,
          ),
        ],
      ),
    );
  }
}

class _TypeRow extends StatelessWidget {
  final String type;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const _TypeRow({
    required this.type,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            MonoText(selected ? '▸ ' : '  ', color: AppColors.phosphor),
            MonoText(
              type.toUpperCase(),
              color: selected ? AppColors.fgPrimary : AppColors.fgSecondary,
              size: 13,
            ),
            MonoText('   —  $description', color: AppColors.fgMuted, size: 11),
          ],
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final GeoRandomSuccess state;
  final VoidCallback onGenerateAgain;

  const _ResultView({required this.state, required this.onGenerateAgain});

  @override
  Widget build(BuildContext context) {
    final point = state.point;
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(point.lat, point.lng),
            initialZoom: 15,
            backgroundColor: AppColors.bgVoid,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.situationist.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(point.lat, point.lng),
                  width: 20,
                  height: 20,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.phosphor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Positioned(
          top: 16,
          left: 16,
          child: GestureDetector(
            onTap: () => context.pop(),
            child: const Text(
              '← VOLVER',
              style: TextStyle(
                color: AppColors.fgMuted,
                fontFamily: 'JetBrainsMono',
                fontSize: 11,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 24,
          child: Column(
            children: [
              MonoText(point.type.toUpperCase(), color: AppColors.fgPrimary),
              const SizedBox(height: 8),
              VoidButton(label: 'GENERAR OTRO', onPressed: onGenerateAgain),
            ],
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Verify it compiles**

Run: `cd mobile && flutter analyze lib/features/georandom`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add mobile/lib/features/georandom/pages/
git commit -m "feat(georandom): add GeoRandomPage UI (radius slider, type selector, map result)"
```

---

### Task 13: Wire into app.dart and add entry button on MapPage

**Files:**
- Modify: `mobile/lib/app.dart`
- Modify: `mobile/lib/features/map/pages/map_page.dart`

- [ ] **Step 1: Register the bloc and route in `app.dart`**

Add imports near the other feature imports:

```dart
import 'features/georandom/bloc/georandom_bloc.dart';
import 'features/georandom/data/georandom_repository.dart';
import 'features/georandom/pages/georandom_page.dart';
```

Add the bloc field next to `late final MapBloc _mapBloc;`:

```dart
  late final GeoRandomBloc _geoRandomBloc;
```

Initialize it in `initState`, right after `_mapBloc = MapBloc(...)`:

```dart
    _geoRandomBloc = GeoRandomBloc(
      repository: GeoRandomRepository(_apiClient),
      locationService: _locationService,
    );
```

Add the route (outside the `StatefulShellRoute`, alongside `/home/create-event` etc.):

```dart
        GoRoute(
          path: '/home/explore',
          builder: (_, __) => const GeoRandomPage(),
        ),
```

Add disposal in `dispose()`:

```dart
    _geoRandomBloc.close();
```

Add the provider in `MultiBlocProvider.providers`:

```dart
          BlocProvider.value(value: _geoRandomBloc),
```

- [ ] **Step 2: Add the entry button on `MapPage`**

In `mobile/lib/features/map/pages/map_page.dart`, add the import:

```dart
import 'package:go_router/go_router.dart';
```

In `_MapReady.build`, inside the `Stack` `children`, right after the `MarkerLayer` closing and before the conditional sheets (`if (state.selectedCluster != null) ...`), add:

```dart
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => context.push('/home/explore'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.bgVoid.withValues(alpha: 0.8),
                  border: Border.all(color: AppColors.fgMuted, width: 1),
                ),
                child: const Text(
                  '◈ EXPLORAR',
                  style: TextStyle(
                    color: AppColors.phosphor,
                    fontFamily: 'JetBrainsMono',
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),
```

- [ ] **Step 3: Verify it compiles**

Run: `cd mobile && flutter analyze lib/app.dart lib/features/map/pages/map_page.dart`
Expected: No issues found

- [ ] **Step 4: Commit**

```bash
git add mobile/lib/app.dart mobile/lib/features/map/pages/map_page.dart
git commit -m "feat(georandom): wire GeoRandomBloc/route into app.dart, add Explorar entry button on MapPage"
```

---

### Task 14: Full verification

**Files:** none (verification only)

- [ ] **Step 1: Run the full backend test suite**

Run: `dotnet test backend/tests/UnitTests`
Expected: PASS (all tests, no regressions)

- [ ] **Step 2: Run the full backend build**

Run: `dotnet build backend/src/Api`
Expected: Build succeeded, 0 errors, 0 warnings introduced by this change

- [ ] **Step 3: Run mobile static analysis**

Run: `cd mobile && flutter analyze --fatal-warnings`
Expected: No fatal warnings (per project convention, `info`-level hints are acceptable — do not use `--fatal-infos`)

- [ ] **Step 4: Run the full mobile test suite**

Run: `cd mobile && flutter test`
Expected: PASS (all tests, no regressions)

- [ ] **Step 5: Manual smoke test (requires a running backend + emulator/device)**

Run backend: `dotnet run --project backend/src/Api`
Run mobile: `cd mobile && flutter run`

Walk through:
1. Log in, land on the Map tab.
2. Tap "◈ EXPLORAR" top-right → navigates to `/home/explore`.
3. Move the radius slider, pick each of the 3 types, tap "GENERAR".
4. Confirm a marker appears on the map at a plausible nearby location, and the type label shows.
5. Tap "GENERAR OTRO" — confirm a new point is generated without leaving the screen.
6. Tap "← VOLVER" — confirm it returns to the Map tab (not a blank screen — this is the `push()` vs `go()` pitfall documented in CLAUDE.md).
7. Deny location permission (via OS settings) and repeat step 3 — confirm the explicit permission-required message appears instead of silently using a fallback location.
8. Tap "GENERAR" twice within 4 seconds — confirm the second attempt surfaces the rate-limit error message.

If no emulator/device is available in this environment, stop after Step 4 and report that manual verification is pending.

- [ ] **Step 6: Final commit (only if manual fixes were needed)**

If the smoke test required any fixes, commit them individually with descriptive messages before considering this plan complete.

---

## Self-review notes

- **Spec coverage:** every FR/NFR carved into scope by the design doc (contract, algorithm, error handling, testing, explicit exclusions) has a corresponding task. Everything under "Explícitamente fuera de alcance" in the spec is intentionally absent here.
- **Type consistency checked:** `GeoRandomPointType` (Infrastructure.Geo) is parsed from the same string values validated by `GenerateGeoRandomPointCommandValidator` ("Atractor"/"Vacio"/"Anomalia", case-insensitive) and produced by `GeoRandomPointResponse.Type` via `type.ToString()`. `KdeCalculator.SelectPoint`'s signature (`ExclusionRing`/`PoiPoint` from `GeoRandomTypes.cs`) matches what `OverpassResult` (Task 4) and the handler (Task 6) pass in. Mobile's `GeoRandomPointModel` field names (`lat`,`lng`,`type`,`generatedAt`) match the backend's default camelCase JSON output (`Lat`,`Lng`,`Type`,`GeneratedAt`).
