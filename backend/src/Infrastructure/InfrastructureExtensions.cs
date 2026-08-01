using Infrastructure.Ai;
using Infrastructure.Cache;
using Infrastructure.Geo;
using Infrastructure.Persistence;
using Infrastructure.Workers;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using StackExchange.Redis;

namespace Infrastructure;

public static class InfrastructureExtensions
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration config)
    {
        // PostgreSQL + PostGIS
        services.AddDbContext<AppDbContext>(options =>
            options.UseNpgsql(
                config.GetConnectionString("Postgres"),
                o => o.UseNetTopologySuite()));

        // Redis — ssl=True required for Upstash; abortConnect=false prevents startup crash
        services.AddSingleton<IConnectionMultiplexer>(_ =>
        {
            var redisConfig = ConfigurationOptions.Parse(config.GetConnectionString("Redis")!);
            redisConfig.AbortOnConnectFail = false;
            redisConfig.Ssl = redisConfig.EndPoints.Any(ep =>
                ep.ToString()!.Contains("upstash.io"));
            return ConnectionMultiplexer.Connect(redisConfig);
        });
        services.AddScoped<IRedisCacheService, RedisCacheService>();

        // Local content service (no external AI API required)
        services.AddSingleton<IAnthropicClient, LocalContentService>();

        // GeoRandom (Módulo A) — Overpass client, geohash cache, KDE calculator
        services.AddHttpClient<IOverpassClient, OverpassClient>(client =>
        {
            client.BaseAddress = new Uri(config["Overpass:BaseUrl"] ?? "https://overpass-api.de/api/");
            client.Timeout = TimeSpan.FromSeconds(30);
            client.DefaultRequestHeaders.Add("User-Agent", "TheSituationistApp/1.0 (+https://github.com/marblaleb/The-Situationist-App)");
        });
        services.AddScoped<IGeoRandomCacheService, GeoRandomCacheService>();
        services.AddSingleton<IRandomSource, CryptoRandomSource>();
        services.AddSingleton<KdeCalculator>();

        // Background workers
        services.AddHostedService<EventExpirationWorker>();

        return services;
    }
}
