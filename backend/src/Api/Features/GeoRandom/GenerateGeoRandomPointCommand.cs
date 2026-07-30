using FluentValidation;
using Infrastructure.Cache;
using Infrastructure.Geo;
using MediatR;
using StackExchange.Redis;
using System.Text.Json;

namespace Api.Features.GeoRandom;

public record GenerateGeoRandomPointCommand(Guid UserId, GenerateGeoRandomPointRequest Request)
    : IRequest<GeoRandomPointResponse>;

public class GenerateGeoRandomPointCommandValidator : AbstractValidator<GenerateGeoRandomPointCommand>
{
    public GenerateGeoRandomPointCommandValidator()
    {
        RuleFor(x => x.Request.Type)
            .Must(t => Enum.TryParse<GeoRandomPointType>(t, ignoreCase: true, out _))
            .WithMessage("Invalid type. Valid values: Atractor, Vacio, Anomalia");
        RuleFor(x => x.Request.Latitude).InclusiveBetween(-90, 90);
        RuleFor(x => x.Request.Longitude).InclusiveBetween(-180, 180);
        RuleFor(x => x.Request.RadiusMeters).InclusiveBetween(500, 5000);
    }
}

public class RateLimitExceededException(TimeSpan retryAfter) : Exception
{
    public TimeSpan RetryAfter { get; } = retryAfter;
}

public class GeoDataUnavailableException(string message, Exception? innerException = null)
    : Exception(message, innerException);

public class GenerateGeoRandomPointCommandHandler(
    IGeoRandomCacheService cache,
    KdeCalculator kde,
    IRedisCacheService throttle) : IRequestHandler<GenerateGeoRandomPointCommand, GeoRandomPointResponse>
{
    private static readonly TimeSpan ThrottleWindow = TimeSpan.FromSeconds(4);

    public async Task<GeoRandomPointResponse> Handle(GenerateGeoRandomPointCommand request, CancellationToken ct)
    {
        try
        {
            var throttleKey = $"georandom:throttle:{request.UserId}";
            var acquired = await throttle.SetIfNotExistsAsync(throttleKey, "1", ThrottleWindow);
            if (!acquired)
                throw new RateLimitExceededException(ThrottleWindow);

            var data = await cache.GetOrFetchAsync(request.Request.Latitude, request.Request.Longitude, ct);

            var type = Enum.Parse<GeoRandomPointType>(request.Request.Type, ignoreCase: true);
            var (lat, lng) = kde.SelectPoint(
                request.Request.Latitude,
                request.Request.Longitude,
                request.Request.RadiusMeters,
                type,
                data.Pois,
                data.ExclusionRings);

            return new GeoRandomPointResponse(lat, lng, type.ToString(), DateTimeOffset.UtcNow);
        }
        catch (Exception ex) when (
            ex is HttpRequestException or TaskCanceledException or RedisException or JsonException
            && !ct.IsCancellationRequested)
        {
            throw new GeoDataUnavailableException(
                "No pudimos generar un punto ahora, intentá de nuevo en unos minutos.", ex);
        }
    }
}
