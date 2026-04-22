using Api.Features.Missions;
using Domain;
using Domain.Entities;
using FluentAssertions;
using Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace UnitTests.Handlers;

public class RequestClueHintCommandHandlerTests
{
    private static AppDbContext CreateDb() =>
        new(new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options);

    private static (MissionProgress progress, Clue clue) SeedActiveProgress(
        AppDbContext db, string? hint = "Pista de prueba")
    {
        var missionId = Guid.NewGuid();
        var userId = Guid.NewGuid();
        var clue = new Clue
        {
            Id = Guid.NewGuid(),
            MissionId = missionId,
            Order = 1,
            Type = ClueType.Textual,
            Content = "Contenido de la pista",
            Hint = hint,
            AnswerHash = "hash",
            IsOptional = false
        };
        var progress = new MissionProgress
        {
            Id = Guid.NewGuid(),
            MissionId = missionId,
            UserId = userId,
            CurrentClueId = clue.Id,
            StartedAt = DateTimeOffset.UtcNow,
            Status = MissionProgressStatus.InProgress,
            HintsUsed = 0
        };
        db.Clues.Add(clue);
        db.MissionProgresses.Add(progress);
        db.SaveChanges();
        return (progress, clue);
    }

    [Fact]
    public async Task ThrowsKeyNotFound_WhenNoActiveProgress()
    {
        await using var db = CreateDb();
        var handler = new RequestClueHintCommandHandler(db);

        var act = () => handler.Handle(
            new RequestClueHintCommand(Guid.NewGuid(), Guid.NewGuid(), Guid.NewGuid()),
            CancellationToken.None);

        await act.Should().ThrowAsync<KeyNotFoundException>()
            .WithMessage("*No active progress*");
    }

    [Fact]
    public async Task ThrowsInvalidOperation_WhenClueIsNotCurrent()
    {
        await using var db = CreateDb();
        var (progress, _) = SeedActiveProgress(db);
        var handler = new RequestClueHintCommandHandler(db);

        var act = () => handler.Handle(
            new RequestClueHintCommand(progress.MissionId, Guid.NewGuid(), progress.UserId), // ClueId distinto
            CancellationToken.None);

        await act.Should().ThrowAsync<InvalidOperationException>()
            .WithMessage("*not the current clue*");
    }

    [Fact]
    public async Task ReturnsHintText_WhenClueHasHint()
    {
        await using var db = CreateDb();
        var (progress, clue) = SeedActiveProgress(db, hint: "Mira hacia el norte");
        var handler = new RequestClueHintCommandHandler(db);

        var result = await handler.Handle(
            new RequestClueHintCommand(progress.MissionId, clue.Id, progress.UserId),
            CancellationToken.None);

        result.Should().Be("Mira hacia el norte");
    }

    [Fact]
    public async Task ReturnsNull_WhenClueHasNoHint()
    {
        await using var db = CreateDb();
        var (progress, clue) = SeedActiveProgress(db, hint: null);
        var handler = new RequestClueHintCommandHandler(db);

        var result = await handler.Handle(
            new RequestClueHintCommand(progress.MissionId, clue.Id, progress.UserId),
            CancellationToken.None);

        result.Should().BeNull();
    }

    [Fact]
    public async Task IncrementsHintsUsed_WhenClueHasHint()
    {
        await using var db = CreateDb();
        var (progress, clue) = SeedActiveProgress(db, hint: "Pista válida");
        var handler = new RequestClueHintCommandHandler(db);

        await handler.Handle(
            new RequestClueHintCommand(progress.MissionId, clue.Id, progress.UserId),
            CancellationToken.None);

        var updated = await db.MissionProgresses.FindAsync(progress.Id);
        updated!.HintsUsed.Should().Be(1);
    }

    [Fact]
    public async Task DoesNotIncrementHintsUsed_WhenClueHasNoHint()
    {
        await using var db = CreateDb();
        var (progress, clue) = SeedActiveProgress(db, hint: null);
        var handler = new RequestClueHintCommandHandler(db);

        await handler.Handle(
            new RequestClueHintCommand(progress.MissionId, clue.Id, progress.UserId),
            CancellationToken.None);

        var updated = await db.MissionProgresses.FindAsync(progress.Id);
        updated!.HintsUsed.Should().Be(0);
    }
}
