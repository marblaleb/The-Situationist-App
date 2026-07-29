namespace Infrastructure.Geo;

public record PoiPoint(double Lat, double Lng);
public record GeoCoordinate(double Lat, double Lng);
public record ExclusionRing(IReadOnlyList<GeoCoordinate> Points);
public record OverpassResult(IReadOnlyList<PoiPoint> Pois, IReadOnlyList<ExclusionRing> ExclusionRings);
