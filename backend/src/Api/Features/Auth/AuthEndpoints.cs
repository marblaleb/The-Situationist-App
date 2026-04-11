using Infrastructure.Cache;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.Configuration;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace Api.Features.Auth;

public static class AuthEndpoints
{
    public static IEndpointRouteBuilder MapAuthEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/auth");

        group.MapGet("/login/{provider}", (
            string provider,
            [FromQuery] string? webCallback,
            IConfiguration config) =>
        {
            if (provider == "google")
            {
                var clientId = config["OAuth:Google:ClientId"];
                var redirectUri = Uri.EscapeDataString(config["OAuth:Google:RedirectUri"]!);
                // Encode webCallback in state so we can redirect back after OAuth
                var state = webCallback is not null
                    ? $"web:{Uri.EscapeDataString(webCallback)}"
                    : Guid.NewGuid().ToString("N");
                var url = $"https://accounts.google.com/o/oauth2/v2/auth?client_id={clientId}&redirect_uri={redirectUri}&response_type=code&scope=openid+email&state={Uri.EscapeDataString(state)}";
                return Results.Redirect(url);
            }
            return Results.BadRequest(new { error = "Provider not supported yet" });
        });

        group.MapGet("/callback/{provider}", async (
            string provider,
            [FromQuery] string code,
            [FromQuery] string? state,
            ISender mediator) =>
        {
            var result = await mediator.Send(new HandleOAuthCallbackCommand(provider, code));

            // If state encodes a web callback URL, redirect with token instead of returning JSON
            if (state is not null && state.StartsWith("web:"))
            {
                var webCallback = Uri.UnescapeDataString(state[4..]);
                return Results.Redirect($"{webCallback}?token={Uri.EscapeDataString(result.AccessToken)}");
            }

            return Results.Ok(result);
        });

        group.MapGet("/me", [Authorize] async (ClaimsPrincipal principal, ISender mediator) =>
        {
            var userId = Guid.Parse(principal.FindFirstValue(JwtRegisteredClaimNames.Sub)!);
            var user = await mediator.Send(new GetCurrentUserQuery(userId));
            return user is null ? Results.NotFound() : Results.Ok(user);
        });

        group.MapDelete("/session", [Authorize] async (
            ClaimsPrincipal principal,
            IRedisCacheService cache) =>
        {
            var jti = principal.FindFirstValue(JwtRegisteredClaimNames.Jti)!;
            var expClaim = principal.FindFirstValue(JwtRegisteredClaimNames.Exp)!;
            var expiresAt = DateTimeOffset.FromUnixTimeSeconds(long.Parse(expClaim));
            var ttl = expiresAt - DateTimeOffset.UtcNow;
            if (ttl > TimeSpan.Zero)
                await cache.SetAsync($"auth:blacklist:{jti}", "1", ttl);
            return Results.NoContent();
        });

        return app;
    }
}
