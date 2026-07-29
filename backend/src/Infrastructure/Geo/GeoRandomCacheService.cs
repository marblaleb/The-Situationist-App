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
    private const int FetchRadiusMeters = 8500;
    private static readonly TimeSpan CacheTtl = TimeSpan.FromDays(7);
    private static readonly JsonSerializerOptions JsonOptions = new(JsonSerializerDefaults.Web);

    public async Task<OverpassResult> GetOrFetchAsync(double lat, double lng, CancellationToken ct = default)
    {
        var geohash = GeoHash.Encode(lat, lng, 5);
        var key = $"georandom:overpass:{geohash}";
        var cached = await cache.GetAsync(key);
        if (cached is not null)
            return JsonSerializer.Deserialize<OverpassResult>(cached, JsonOptions)!;

        var cellCenter = GeoHash.Decode(geohash).Coordinates;
        var result = await overpass.FetchAsync(cellCenter.Lat, cellCenter.Lon, FetchRadiusMeters, ct);
        await cache.SetAsync(key, JsonSerializer.Serialize(result, JsonOptions), CacheTtl);
        return result;
    }
}
