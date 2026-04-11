using Domain;
using Domain.Entities;
using Infrastructure.Ai;
using Infrastructure.Persistence;
using MediatR;
using Microsoft.EntityFrameworkCore;
using NGeoHash;
using System.Text.Json;

namespace Api.Features.Deriva;

public record GetNextDerivaInstructionCommand(
    Guid SessionId,
    Guid UserId,
    double Latitude,
    double Longitude,
    string Language = "es") : IRequest<DerivaInstructionResponse>;

public class GetNextDerivaInstructionCommandHandler(
    AppDbContext db,
    IAnthropicClient ai) : IRequestHandler<GetNextDerivaInstructionCommand, DerivaInstructionResponse>
{
    public async Task<DerivaInstructionResponse> Handle(GetNextDerivaInstructionCommand request, CancellationToken ct)
    {
        var session = await db.DerivaSessions
            .Include(s => s.Instructions.OrderByDescending(i => i.GeneratedAt).Take(1))
            .FirstOrDefaultAsync(s => s.Id == request.SessionId && s.UserId == request.UserId, ct)
            ?? throw new KeyNotFoundException("Session not found");

        if (session.Status != DerivaStatus.Active)
            throw new InvalidOperationException("Session is not active");

        var previous = session.Instructions.FirstOrDefault()?.Content;
        var hour = DateTimeOffset.UtcNow.Hour;
        var timeOfDay = hour < 12 ? "mañana" : hour < 20 ? "tarde" : "noche";
        var geohash5 = GeoHash.Encode(request.Latitude, request.Longitude, 5);

        var context = new DerivaContext(session.Type.ToString(), timeOfDay, geohash5, previous, request.Language);
        var result = await ai.GenerateDerivaInstructionAsync(context, ct);

        var snapshot = new { derivaType = session.Type.ToString(), timeOfDay, geohash5, language = request.Language };
        var instruction = new Domain.Entities.DerivaInstruction
        {
            Id = Guid.NewGuid(),
            SessionId = session.Id,
            Content = result.Content,
            GeneratedAt = DateTimeOffset.UtcNow,
            ContextSnapshot = JsonDocument.Parse(JsonSerializer.Serialize(snapshot))
        };

        db.DerivaInstructions.Add(instruction);
        await db.SaveChangesAsync(ct);

        return new DerivaInstructionResponse(instruction.Id, instruction.Content, instruction.GeneratedAt);
    }
}
