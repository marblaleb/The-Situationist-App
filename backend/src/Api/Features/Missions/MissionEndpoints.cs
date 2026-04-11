using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Routing;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace Api.Features.Missions;

public static class MissionEndpoints
{
    public static IEndpointRouteBuilder MapMissionEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/missions").RequireAuthorization();

        group.MapPost("/", async (CreateMissionRequest req, ClaimsPrincipal principal, ISender mediator) =>
        {
            var userId = Guid.Parse(principal.FindFirstValue(JwtRegisteredClaimNames.Sub)!);
            var result = await mediator.Send(new CreateMissionCommand(userId, req));
            return Results.Created($"/missions/{result.Id}", result);
        });

        group.MapGet("/", async (
            [FromQuery] double lat,
            [FromQuery] double lng,
            [FromQuery] int radius,
            ISender mediator) =>
        {
            var result = await mediator.Send(new GetNearbyMissionsQuery(lat, lng, radius));
            return Results.Ok(result);
        });

        group.MapGet("/{id:guid}", async (Guid id, ISender mediator) =>
        {
            var result = await mediator.Send(new GetMissionDetailQuery(id));
            return result is null ? Results.NotFound() : Results.Ok(result);
        });

        group.MapPost("/{id:guid}/start", async (Guid id, ClaimsPrincipal principal, ISender mediator) =>
        {
            var userId = Guid.Parse(principal.FindFirstValue(JwtRegisteredClaimNames.Sub)!);
            try
            {
                var result = await mediator.Send(new StartMissionCommand(id, userId));
                return Results.Ok(result);
            }
            catch (KeyNotFoundException)
            {
                return Results.NotFound();
            }
            catch (InvalidOperationException ex)
            {
                return Results.Conflict(new { error = ex.Message });
            }
        });

        group.MapPost("/{id:guid}/clues/{clueId:guid}/submit", async (
            Guid id,
            Guid clueId,
            SubmitClueAnswerRequest req,
            ClaimsPrincipal principal,
            ISender mediator) =>
        {
            var userId = Guid.Parse(principal.FindFirstValue(JwtRegisteredClaimNames.Sub)!);
            try
            {
                var result = await mediator.Send(new SubmitClueAnswerCommand(id, clueId, userId, req.Answer));
                return Results.Ok(result);
            }
            catch (KeyNotFoundException)
            {
                return Results.NotFound();
            }
            catch (InvalidOperationException ex)
            {
                return Results.Conflict(new { error = ex.Message });
            }
        });

        group.MapGet("/{id:guid}/progress", async (Guid id, ClaimsPrincipal principal, ISender mediator) =>
        {
            var userId = Guid.Parse(principal.FindFirstValue(JwtRegisteredClaimNames.Sub)!);
            var result = await mediator.Send(new GetMissionProgressQuery(id, userId));
            return result is null ? Results.NotFound() : Results.Ok(result);
        });

        group.MapPost("/{id:guid}/clues/{clueId:guid}/hint", async (
            Guid id,
            Guid clueId,
            ClaimsPrincipal principal,
            ISender mediator) =>
        {
            var userId = Guid.Parse(principal.FindFirstValue(JwtRegisteredClaimNames.Sub)!);
            try
            {
                var hint = await mediator.Send(new RequestClueHintCommand(id, clueId, userId));
                return hint is null
                    ? Results.NotFound(new { error = "No hint available for this clue" })
                    : Results.Ok(new { hint });
            }
            catch (KeyNotFoundException)
            {
                return Results.NotFound();
            }
            catch (InvalidOperationException ex)
            {
                return Results.Conflict(new { error = ex.Message });
            }
        });

        return app;
    }
}
