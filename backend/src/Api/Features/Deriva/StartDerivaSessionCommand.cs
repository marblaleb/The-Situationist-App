using Domain;
using Domain.Entities;
using FluentValidation;
using Infrastructure.Ai;
using Infrastructure.Persistence;
using MediatR;
using Microsoft.EntityFrameworkCore;
using NGeoHash;
using System.Text.Json;

namespace Api.Features.Deriva;

public record StartDerivaSessionCommand(Guid UserId, StartDerivaRequest Request) : IRequest<DerivaSessionResponse>;

public class StartDerivaSessionCommandValidator : AbstractValidator<StartDerivaSessionCommand>
{
    public StartDerivaSessionCommandValidator()
    {
        RuleFor(x => x.Request.Type)
            .Must(t => Enum.TryParse<DerivaType>(t, ignoreCase: true, out _))
            .WithMessage("Invalid deriva type. Valid values: Caotica, Poetica, Social, Sensorial");
        RuleFor(x => x.Request.Latitude).InclusiveBetween(-90, 90);
        RuleFor(x => x.Request.Longitude).InclusiveBetween(-180, 180);
    }
}

public class StartDerivaSessionCommandHandler(
    AppDbContext db,
    IAnthropicClient ai) : IRequestHandler<StartDerivaSessionCommand, DerivaSessionResponse>
{
    public async Task<DerivaSessionResponse> Handle(StartDerivaSessionCommand request, CancellationToken ct)
    {
        // Abandon any existing active session before starting a new one
        var existing = await db.DerivaSessions
            .Where(s => s.UserId == request.UserId && s.Status == DerivaStatus.Active)
            .ToListAsync(ct);
        foreach (var old in existing)
            old.Status = DerivaStatus.Abandoned;

        var type = Enum.Parse<DerivaType>(request.Request.Type, ignoreCase: true);
        var now = DateTimeOffset.UtcNow;

        var session = new DerivaSession
        {
            Id = Guid.NewGuid(),
            UserId = request.UserId,
            Type = type,
            StartedAt = now,
            Status = DerivaStatus.Active
        };

        db.DerivaSessions.Add(session);
        await db.SaveChangesAsync(ct);

        // Generate first instruction
        var instruction = await GenerateInstructionAsync(session, request.Request.Latitude, request.Request.Longitude, null, request.Request.Language, ct);

        return new DerivaSessionResponse(session.Id, session.Type.ToString(), session.StartedAt, session.Status.ToString(), instruction.Content);
    }

    private async Task<Domain.Entities.DerivaInstruction> GenerateInstructionAsync(
        DerivaSession session, double lat, double lng, string? previous, string language, CancellationToken ct)
    {
        var hour = DateTimeOffset.UtcNow.Hour;
        var timeOfDay = hour < 12 ? "mañana" : hour < 20 ? "tarde" : "noche";
        var geohash5 = GeoHash.Encode(lat, lng, 5);

        var context = new DerivaContext(session.Type.ToString(), timeOfDay, geohash5, previous, language);
        var result = await ai.GenerateDerivaInstructionAsync(context, ct);

        var snapshot = new { derivaType = session.Type.ToString(), timeOfDay, geohash5, language };
        var instruction = new Domain.Entities.DerivaInstruction
        {
            Id = Guid.NewGuid(),
            SessionId = session.Id,
            Content = result.Content,
            GeneratedAt = DateTimeOffset.UtcNow,
            ContextSnapshot = JsonDocument.Parse(System.Text.Json.JsonSerializer.Serialize(snapshot))
        };

        db.DerivaInstructions.Add(instruction);
        await db.SaveChangesAsync(ct);
        return instruction;
    }
}
