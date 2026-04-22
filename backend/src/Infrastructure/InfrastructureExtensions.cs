using Infrastructure.Ai;
using Infrastructure.Cache;
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

        // Background workers
        services.AddHostedService<EventExpirationWorker>();

        return services;
    }
}
