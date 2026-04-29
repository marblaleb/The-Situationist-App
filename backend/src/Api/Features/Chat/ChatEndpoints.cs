using Infrastructure.Persistence;
using Infrastructure.SignalR;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.EntityFrameworkCore;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace Api.Features.Chat;

public static class ChatEndpoints
{
    public static IEndpointRouteBuilder MapChatEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/events").RequireAuthorization();

        group.MapGet("/{id:guid}/messages", async (
            Guid id,
            ClaimsPrincipal principal,
            AppDbContext db,
            ISender mediator) =>
        {
            var userId = Guid.Parse(principal.FindFirstValue(JwtRegisteredClaimNames.Sub)!);

            var evt = await db.Events
                .Include(e => e.Participations)
                .FirstOrDefaultAsync(e => e.Id == id);

            if (evt is null) return Results.NotFound();

            var isCreator = evt.CreatorId == userId;
            var isParticipant = evt.Participations.Any(p => p.UserId == userId);

            if (!isCreator && !isParticipant) return Results.Forbid();

            var result = await mediator.Send(new GetChatMessagesQuery(id));
            return Results.Ok(result);
        });

        return app;
    }
}
