using Api.Features.Deriva;
using Domain;
using Domain.Entities;
using FluentAssertions;
using Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace UnitTests.Handlers;

public class CompleteDerivaSessionCommandHandlerTests
{
    private static AppDbContext CreateDb() =>
        new(new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options);

    private static DerivaSession ActiveSession(Guid userId) => new()
    {
        Id = Guid.NewGuid(),
        UserId = userId,
        Type = DerivaType.Social,
        StartedAt = DateTimeOffset.UtcNow.AddMinutes(-30),
        Status = DerivaStatus.Active
    };

    [Fact]
    public async Task ThrowsKeyNotFound_WhenSessionDoesNotExist()
    {
        await using var db = CreateDb();
        var handler = new CompleteDerivaSessionCommandHandler(db);

        var act = () => handler.Handle(
            new CompleteDerivaSessionCommand(Guid.NewGuid(), Guid.NewGuid()),
            CancellationToken.None);

        await act.Should().ThrowAsync<KeyNotFoundException>()
            .WithMessage("*Session not found*");
    }

    [Fact]
    public async Task ThrowsKeyNotFound_WhenSessionBelongsToDifferentUser()
    {
        await using var db = CreateDb();
        var session = ActiveSession(Guid.NewGuid());
        db.DerivaSessions.Add(session);
        await db.SaveChangesAsync();

        var handler = new CompleteDerivaSessionCommandHandler(db);

        var act = () => handler.Handle(
            new CompleteDerivaSessionCommand(session.Id, Guid.NewGuid()),
            CancellationToken.None);

        await act.Should().ThrowAsync<KeyNotFoundException>();
    }

    [Theory]
    [InlineData(DerivaStatus.Completed)]
    [InlineData(DerivaStatus.Abandoned)]
    public async Task ThrowsInvalidOperation_WhenSessionIsNotActive(DerivaStatus status)
    {
        await using var db = CreateDb();
        var userId = Guid.NewGuid();
        var session = ActiveSession(userId);
        session.Status = status;
        db.DerivaSessions.Add(session);
        await db.SaveChangesAsync();

        var handler = new CompleteDerivaSessionCommandHandler(db);

        var act = () => handler.Handle(
            new CompleteDerivaSessionCommand(session.Id, userId),
            CancellationToken.None);

        await act.Should().ThrowAsync<InvalidOperationException>()
            .WithMessage("*not active*");
    }

    [Fact]
    public async Task SetsStatusToCompleted_WhenSessionIsActive()
    {
        await using var db = CreateDb();
        var userId = Guid.NewGuid();
        var session = ActiveSession(userId);
        db.DerivaSessions.Add(session);
        await db.SaveChangesAsync();

        var handler = new CompleteDerivaSessionCommandHandler(db);
        await handler.Handle(new CompleteDerivaSessionCommand(session.Id, userId), CancellationToken.None);

        var updated = await db.DerivaSessions.FindAsync(session.Id);
        updated!.Status.Should().Be(DerivaStatus.Completed);
    }

    [Fact]
    public async Task SetsEndedAt_WhenSessionIsCompleted()
    {
        await using var db = CreateDb();
        var userId = Guid.NewGuid();
        var session = ActiveSession(userId);
        db.DerivaSessions.Add(session);
        await db.SaveChangesAsync();

        var before = DateTimeOffset.UtcNow;
        var handler = new CompleteDerivaSessionCommandHandler(db);
        await handler.Handle(new CompleteDerivaSessionCommand(session.Id, userId), CancellationToken.None);

        var updated = await db.DerivaSessions.FindAsync(session.Id);
        updated!.EndedAt.Should().NotBeNull();
        updated.EndedAt.Should().BeOnOrAfter(before);
    }

    [Fact]
    public async Task CreatesActivityLog_WithDerivaCompletedType()
    {
        await using var db = CreateDb();
        var userId = Guid.NewGuid();
        var session = ActiveSession(userId);
        db.DerivaSessions.Add(session);
        await db.SaveChangesAsync();

        var handler = new CompleteDerivaSessionCommandHandler(db);
        await handler.Handle(new CompleteDerivaSessionCommand(session.Id, userId), CancellationToken.None);

        var log = await db.ActivityLogs.FirstOrDefaultAsync(l => l.UserId == userId);
        log.Should().NotBeNull();
        log!.Type.Should().Be(ActivityLogType.DerivaCompleted);
        log.ReferenceId.Should().Be(session.Id);
    }
}
