using FluentValidation;
using Infrastructure.Cache;
using Infrastructure.Geo;
using MediatR;

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

public class RateLimitExceededException : Exception;

public class GeoDataUnavailableException(string message) : Exception(message);

public class GenerateGeoRandomPointCommandHandler(
    IGeoRandomCacheService cache,
    KdeCalculator kde,
    IRedisCacheService throttle) : IRequestHandler<GenerateGeoRandomPointCommand, GeoRandomPointResponse>
{
    private static readonly TimeSpan ThrottleWindow = TimeSpan.FromSeconds(4);

    public async Task<GeoRandomPointResponse> Handle(GenerateGeoRandomPointCommand request, CancellationToken ct)
    {
        var throttleKey = $"georandom:throttle:{request.UserId}";
        if (await throttle.ExistsAsync(throttleKey))
            throw new RateLimitExceededException();
        await throttle.SetAsync(throttleKey, "1", ThrottleWindow);

        OverpassResult data;
        try
        {
            data = await cache.GetOrFetchAsync(request.Request.Latitude, request.Request.Longitude, ct);
        }
        catch (HttpRequestException)
        {
            throw new GeoDataUnavailableException(
                "No pudimos generar un punto ahora, intentá de nuevo en unos minutos.");
        }

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
}
