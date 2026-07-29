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
