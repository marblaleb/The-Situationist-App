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
