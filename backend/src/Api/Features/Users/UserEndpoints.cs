using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Routing;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace Api.Features.Users;

public static class UserEndpoints
{
    public static IEndpointRouteBuilder MapUserEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/users");

        group.MapGet("/username-available", async (
            [FromQuery] string username,
            ISender mediator) =>
        {
            var available = await mediator.Send(new CheckUsernameAvailabilityQuery(username));
            return Results.Ok(new { available });
        });

        group.MapPost("/me/username", [Authorize] async (
            [FromBody] SetUsernameRequest request,
            ClaimsPrincipal principal,
            ISender mediator) =>
        {
            var userId = Guid.Parse(principal.FindFirstValue(JwtRegisteredClaimNames.Sub)!);
            try
            {
                var result = await mediator.Send(new SetUsernameCommand(userId, request.Username));
                return Results.Ok(new { accessToken = result.AccessToken });
            }
            catch (InvalidOperationException ex) when (ex.Message.Contains("already taken"))
            {
                return Results.Conflict(new { error = ex.Message });
            }
        });

        group.MapPut("/me/username", [Authorize] async (
            [FromBody] SetUsernameRequest request,
            ClaimsPrincipal principal,
            ISender mediator) =>
        {
            var userId = Guid.Parse(principal.FindFirstValue(JwtRegisteredClaimNames.Sub)!);
            try
            {
                var result = await mediator.Send(new SetUsernameCommand(userId, request.Username));
                return Results.Ok(new { accessToken = result.AccessToken });
            }
            catch (InvalidOperationException ex) when (ex.Message.Contains("already taken"))
            {
                return Results.Conflict(new { error = ex.Message });
            }
        });

        return app;
    }
}

public record SetUsernameRequest(string Username);
