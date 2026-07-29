namespace Api.Features.GeoRandom;

public record GenerateGeoRandomPointRequest(double Latitude, double Longitude, int RadiusMeters, string Type);

public record GeoRandomPointResponse(double Lat, double Lng, string Type, DateTimeOffset GeneratedAt);
