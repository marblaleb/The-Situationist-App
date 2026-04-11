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

        // Redis
        services.AddSingleton<IConnectionMultiplexer>(_ =>
            ConnectionMultiplexer.Connect(config.GetConnectionString("Redis")!));
        services.AddScoped<IRedisCacheService, RedisCacheService>();

        // Local content service (no external AI API required)
        services.AddSingleton<IAnthropicClient, LocalContentService>();

        // Background workers
        services.AddHostedService<EventExpirationWorker>();

        return services;
    }
}
