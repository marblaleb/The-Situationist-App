using Infrastructure.SignalR;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;

namespace Api.Features.Chat;

public static class ChatEndpoints
{
    public static IEndpointRouteBuilder MapChatEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/events").RequireAuthorization();

        group.MapGet("/{id:guid}/messages", async (Guid id, ISender mediator) =>
        {
            var result = await mediator.Send(new GetChatMessagesQuery(id));
            return Results.Ok(result);
        });

        return app;
    }
}
