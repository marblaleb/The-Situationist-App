using NetTopologySuite;
using NetTopologySuite.Geometries;
using NetTopologySuite.Index.Strtree;

namespace Infrastructure.Geo;

public enum GeoRandomPointType { Atractor, Vacio, Anomalia }

public class NoValidGeoRandomPointException(string message) : Exception(message);

public class KdeCalculator(IRandomSource random)
{
    private const double BandwidthMeters = 120.0;
    private const int CandidateCount = 3000;
    private const int MaxRetries = 10;
    private const double StdDevEpsilon = 1e-9;
    private const int MaxPoiSampleSize = 3000;

    public (double Lat, double Lng) SelectPoint(
        double centerLat,
        double centerLng,
        double radiusMeters,
        GeoRandomPointType type,
        IReadOnlyList<PoiPoint> pois,
        IReadOnlyList<ExclusionRing> exclusionRings)
    {
        var effectivePois = pois.Count > MaxPoiSampleSize
            ? Shuffle(pois.ToList()).Take(MaxPoiSampleSize).ToList()
            : pois;

        var index = effectivePois.Count > 0 ? BuildIndex(effectivePois) : null;
        var candidates = new List<(double Lat, double Lng, double Density)>(CandidateCount);
        for (var i = 0; i < CandidateCount; i++)
        {
            var (lat, lng) = GeoMath.RandomPointInCircle(centerLat, centerLng, radiusMeters, random);
            var density = index is null ? 0 : ComputeDensity(lat, lng, index, radiusMeters);
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

    private List<T> Shuffle<T>(List<T> items)
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

    private static double ComputeDensity(double lat, double lng, STRtree<PoiPoint> index, double radiusMeters)
    {
        var envelopeRadiusMeters = radiusMeters * 2;
        var envelopeDegreesLat = envelopeRadiusMeters / 111_320.0;
        var envelopeDegreesLng = envelopeDegreesLat / Math.Cos(lat * Math.PI / 180.0);
        var envelope = new Envelope(
            lng - envelopeDegreesLng, lng + envelopeDegreesLng,
            lat - envelopeDegreesLat, lat + envelopeDegreesLat);

        const double metersPerDegreeLat = 111_320.0;
        var metersPerDegreeLng = metersPerDegreeLat * Math.Cos(lat * Math.PI / 180.0);

        double density = 0;
        foreach (var poi in index.Query(envelope))
        {
            var dy = (poi.Lat - lat) * metersPerDegreeLat;
            var dx = (poi.Lng - lng) * metersPerDegreeLng;
            var distanceSquaredMeters = dx * dx + dy * dy;
            density += Math.Exp(-distanceSquaredMeters / (2 * BandwidthMeters * BandwidthMeters));
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
