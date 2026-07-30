using FluentValidation;
using Infrastructure.Geo;
using MediatR;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace Api.Features.GeoRandom;

public static class GeoRandomEndpoints
{
    public static IEndpointRouteBuilder MapGeoRandomEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/georandom").RequireAuthorization();

        group.MapPost("/generate", async (
            GenerateGeoRandomPointRequest req,
            ClaimsPrincipal principal,
            ISender mediator,
            IValidator<GenerateGeoRandomPointCommand> validator,
            ILoggerFactory loggerFactory,
            HttpContext httpContext) =>
        {
            var logger = loggerFactory.CreateLogger("Api.Features.GeoRandom.GeoRandomEndpoints");
            var userId = Guid.Parse(principal.FindFirstValue(JwtRegisteredClaimNames.Sub)!);
            var command = new GenerateGeoRandomPointCommand(userId, req);

            // Manual invocation: this backend registers FluentValidation validators in DI
            // but has no MediatR pipeline behavior that invokes them automatically (a
            // pre-existing, codebase-wide gap — see plan doc Task 7 note). Every other
            // endpoint here has the same gap; this one closes it locally.
            var validationResult = await validator.ValidateAsync(command);
            if (!validationResult.IsValid)
            {
                var errors = validationResult.Errors
                    .GroupBy(e => e.PropertyName)
                    .ToDictionary(g => g.Key, g => g.Select(e => e.ErrorMessage).ToArray());
                return Results.ValidationProblem(errors);
            }

            try
            {
                var result = await mediator.Send(command);
                return Results.Ok(result);
            }
            catch (RateLimitExceededException ex)
            {
                httpContext.Response.Headers["Retry-After"] = ((int)ex.RetryAfter.TotalSeconds).ToString();
                return Results.Json(
                    new { error = "límite alcanzado, esperá unos segundos" },
                    statusCode: StatusCodes.Status429TooManyRequests);
            }
            catch (GeoDataUnavailableException ex)
            {
                logger.LogWarning(ex.InnerException, "GeoRandom: Overpass unavailable for user {UserId}", userId);
                return Results.Json(
                    new { error = ex.Message },
                    statusCode: StatusCodes.Status503ServiceUnavailable);
            }
            catch (NoValidGeoRandomPointException)
            {
                return Results.UnprocessableEntity(
                    new { error = "no encontramos una zona válida con este radio, probá un radio mayor" });
            }
        });

        return app;
    }
}
