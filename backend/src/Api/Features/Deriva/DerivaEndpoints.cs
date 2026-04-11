using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Routing;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace Api.Features.Deriva;

public static class DerivaEndpoints
{
    public static IEndpointRouteBuilder MapDerivaEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/deriva/sessions").RequireAuthorization();

        group.MapPost("/", async (StartDerivaRequest req, ClaimsPrincipal principal, ISender mediator) =>
        {
            var userId = Guid.Parse(principal.FindFirstValue(JwtRegisteredClaimNames.Sub)!);
            try
            {
                var result = await mediator.Send(new StartDerivaSessionCommand(userId, req));
                return Results.Created($"/deriva/sessions/{result.Id}", result);
            }
            catch (InvalidOperationException ex)
            {
                return Results.Conflict(new { error = ex.Message });
            }
        });

        group.MapPost("/{id:guid}/next-instruction", async (
            Guid id,
            NextInstructionRequest req,
            ClaimsPrincipal principal,
            ISender mediator) =>
        {
            var userId = Guid.Parse(principal.FindFirstValue(JwtRegisteredClaimNames.Sub)!);
            try
            {
                var result = await mediator.Send(new GetNextDerivaInstructionCommand(id, userId, req.Latitude, req.Longitude, req.Lang ?? "es"));
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

        group.MapPost("/{id:guid}/complete", async (Guid id, ClaimsPrincipal principal, ISender mediator) =>
        {
            var userId = Guid.Parse(principal.FindFirstValue(JwtRegisteredClaimNames.Sub)!);
            try
            {
                await mediator.Send(new CompleteDerivaSessionCommand(id, userId));
                return Results.NoContent();
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

        group.MapPost("/{id:guid}/abandon", async (Guid id, ClaimsPrincipal principal, ISender mediator) =>
        {
            var userId = Guid.Parse(principal.FindFirstValue(JwtRegisteredClaimNames.Sub)!);
            try
            {
                await mediator.Send(new AbandonDerivaSessionCommand(id, userId));
                return Results.NoContent();
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
