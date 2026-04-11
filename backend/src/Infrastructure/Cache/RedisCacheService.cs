using StackExchange.Redis;

namespace Infrastructure.Cache;

public interface IRedisCacheService
{
    Task SetAsync(string key, string value, TimeSpan ttl);
    Task<string?> GetAsync(string key);
    Task RemoveAsync(string key);
    Task<bool> ExistsAsync(string key);
}

public class RedisCacheService(IConnectionMultiplexer redis) : IRedisCacheService
{
    private readonly IDatabase _db = redis.GetDatabase();

    public Task SetAsync(string key, string value, TimeSpan ttl)
        => _db.StringSetAsync(key, value, ttl);

    public async Task<string?> GetAsync(string key)
    {
        var value = await _db.StringGetAsync(key);
        return value.HasValue ? value.ToString() : null;
    }

    public Task RemoveAsync(string key) => _db.KeyDeleteAsync(key);

    public Task<bool> ExistsAsync(string key) => _db.KeyExistsAsync(key);
}
