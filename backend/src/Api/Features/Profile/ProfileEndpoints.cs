using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Routing;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace Api.Features.Profile;

public static class ProfileEndpoints
{
    public static IEndpointRouteBuilder MapProfileEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/profile").RequireAuthorization();

        group.MapGet("/me", async (ClaimsPrincipal principal, ISender mediator) =>
        {
            var userId = Guid.Parse(principal.FindFirstValue(JwtRegisteredClaimNames.Sub)!);
            var result = await mediator.Send(new GetProfileQuery(userId));
            return result is null ? Results.NotFound() : Results.Ok(result);
        });

        group.MapGet("/me/activity", async (
            ClaimsPrincipal principal,
            [FromQuery] string? cursor,
            [FromQuery] int pageSize,
            ISender mediator) =>
        {
            var userId = Guid.Parse(principal.FindFirstValue(JwtRegisteredClaimNames.Sub)!);
            var size = pageSize is > 0 and <= 100 ? pageSize : 20;
            var result = await mediator.Send(new GetActivityLogQuery(userId, cursor, size));
            return Results.Ok(result);
        });

        group.MapGet("/me/events", async (ClaimsPrincipal principal, ISender mediator) =>
        {
            var userId = Guid.Parse(principal.FindFirstValue(JwtRegisteredClaimNames.Sub)!);
            var result = await mediator.Send(new GetUserEventsQuery(userId));
            return Results.Ok(result);
        });

        group.MapGet("/me/missions", async (ClaimsPrincipal principal, ISender mediator) =>
        {
            var userId = Guid.Parse(principal.FindFirstValue(JwtRegisteredClaimNames.Sub)!);
            var result = await mediator.Send(new GetUserMissionsQuery(userId));
            return Results.Ok(result);
        });

        group.MapGet("/me/creation-limits", async (ClaimsPrincipal principal, ISender mediator) =>
        {
            var userId = Guid.Parse(principal.FindFirstValue(JwtRegisteredClaimNames.Sub)!);
            var result = await mediator.Send(new GetCreationLimitsQuery(userId));
            return Results.Ok(result);
        });

        return app;
    }
}
