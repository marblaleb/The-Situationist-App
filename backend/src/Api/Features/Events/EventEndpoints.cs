using Domain;
using Infrastructure.Persistence;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Routing;
using Microsoft.EntityFrameworkCore;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace Api.Features.Events;

public static class EventEndpoints
{
    public static IEndpointRouteBuilder MapEventEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/events").RequireAuthorization();

        group.MapPost("/", async (CreateEventRequest req, ClaimsPrincipal principal, ISender mediator) =>
        {
            var userId = Guid.Parse(principal.FindFirstValue(JwtRegisteredClaimNames.Sub)!);
            try
            {
                var result = await mediator.Send(new CreateEventCommand(userId, req));
                return Results.Created($"/events/{result.Id}", result);
            }
            catch (InvalidOperationException ex)
            {
                return Results.Conflict(new { error = ex.Message });
            }
        });

        group.MapPost("/generate", async (GenerateEventRequest req, ISender mediator) =>
        {
            var result = await mediator.Send(new GenerateEventSuggestionCommand(
                req.ActionType, req.InterventionLevel, req.Latitude, req.Longitude));
            return Results.Ok(result);
        });

        group.MapGet("/", async (
            [FromQuery] double lat,
            [FromQuery] double lng,
            [FromQuery] int radius,
            ISender mediator) =>
        {
            var result = await mediator.Send(new GetNearbyEventsQuery(lat, lng, radius));
            return Results.Ok(result);
        });

        group.MapGet("/{id:guid}", async (
            Guid id,
            [FromQuery] double? lat,
            [FromQuery] double? lng,
            ClaimsPrincipal principal,
            ISender mediator) =>
        {
            var userId = Guid.Parse(principal.FindFirstValue(JwtRegisteredClaimNames.Sub)!);
            var result = await mediator.Send(new GetEventDetailQuery(id, userId, lat, lng));
            return result is null ? Results.NotFound() : Results.Ok(result);
        });

        group.MapPost("/{id:guid}/participate", async (
            Guid id,
            ParticipateRequest req,
            ClaimsPrincipal principal,
            ISender mediator) =>
        {
            var userId = Guid.Parse(principal.FindFirstValue(JwtRegisteredClaimNames.Sub)!);
            try
            {
                await mediator.Send(new ParticipateInEventCommand(id, userId, req.Role));
                return Results.NoContent();
            }
            catch (InvalidOperationException ex)
            {
                return Results.Conflict(new { error = ex.Message });
            }
            catch (KeyNotFoundException)
            {
                return Results.NotFound();
            }
            catch (DbUpdateException)
            {
                return Results.Problem("Database error while saving participation.", statusCode: 500);
            }
        });

        group.MapDelete("/{id:guid}", async (
            Guid id,
            ClaimsPrincipal principal,
            AppDbContext db) =>
        {
            var userId = Guid.Parse(principal.FindFirstValue(JwtRegisteredClaimNames.Sub)!);
            var evt = await db.Events.FindAsync(new object[] { id });
            if (evt is null) return Results.NotFound();
            if (evt.CreatorId != userId) return Results.Forbid();
            evt.Status = EventStatus.Cancelled;
            await db.SaveChangesAsync();
            return Results.NoContent();
        });

        return app;
    }
}
