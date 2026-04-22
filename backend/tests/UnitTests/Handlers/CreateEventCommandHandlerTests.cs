using Api.Features.Events;
using Domain;
using Domain.Entities;
using FluentAssertions;
using Infrastructure.Cache;
using Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using NetTopologySuite.Geometries;
using NSubstitute;

namespace UnitTests.Handlers;

public class CreateEventCommandHandlerTests
{
    private static AppDbContext CreateDb() =>
        new(new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options);

    private static IRedisCacheService CacheMock()
    {
        var mock = Substitute.For<IRedisCacheService>();
        mock.RemoveAsync(Arg.Any<string>()).Returns(Task.CompletedTask);
        return mock;
    }

    private static CreateEventCommand ValidCommand(Guid? creatorId = null) => new(
        creatorId ?? Guid.NewGuid(),
        new CreateEventRequest(
            Title: "Deriva nocturna",
            Description: "Exploración psicogeográfica del barrio viejo",
            ActionType: "Social",
            InterventionLevel: "Bajo",
            Latitude: 40.416,
            Longitude: -3.703,
            RadiusMeters: 200,
            Visibility: "Public",
            MaxParticipants: null,
            StartsAt: DateTimeOffset.UtcNow.AddHours(1),
            DurationMinutes: 45));

    [Fact]
    public async Task ThrowsInvalidOperation_WhenDailyLimitReached()
    {
        await using var db = CreateDb();
        var creatorId = Guid.NewGuid();
        var todayUtc = new DateTimeOffset(DateTimeOffset.UtcNow.Date, TimeSpan.Zero);

        // Simula 2 eventos creados hoy
        for (var i = 0; i < 2; i++)
        {
            db.Events.Add(new Event
            {
                Id = Guid.NewGuid(),
                CreatorId = creatorId,
                Title = $"Evento {i}",
                Description = "desc",
                ActionType = ActionType.Social,
                InterventionLevel = InterventionLevel.Bajo,
                Location = new Point(-3.703, 40.416) { SRID = 4326 },
                RadiusMeters = 100,
                Visibility = EventVisibility.Public,
                StartsAt = DateTimeOffset.UtcNow,
                ExpiresAt = DateTimeOffset.UtcNow.AddHours(1),
                Status = EventStatus.Active,
                CreatedAt = todayUtc
            });
        }
        await db.SaveChangesAsync();

        var handler = new CreateEventCommandHandler(db, CacheMock());

        var act = () => handler.Handle(ValidCommand(creatorId), CancellationToken.None);

        await act.Should().ThrowAsync<InvalidOperationException>()
            .WithMessage("*Daily event creation limit*");
    }

    [Fact]
    public async Task ReturnsEventResponse_WhenCreationSucceeds()
    {
        await using var db = CreateDb();
        var cmd = ValidCommand();
        var handler = new CreateEventCommandHandler(db, CacheMock());

        var result = await handler.Handle(cmd, CancellationToken.None);

        result.Should().NotBeNull();
        result.CreatorId.Should().Be(cmd.CreatorId);
        result.Title.Should().Be(cmd.Request.Title);
        result.Status.Should().Be("Active");
        result.ParticipantCount.Should().Be(0);
    }

    [Fact]
    public async Task PersistsEventToDatabase_WhenCreationSucceeds()
    {
        await using var db = CreateDb();
        var cmd = ValidCommand();
        var handler = new CreateEventCommandHandler(db, CacheMock());

        var result = await handler.Handle(cmd, CancellationToken.None);

        var saved = await db.Events.FindAsync(result.Id);
        saved.Should().NotBeNull();
        saved!.CreatorId.Should().Be(cmd.CreatorId);
    }

    [Fact]
    public async Task SetsExpiresAt_BasedOnStartsAtPlusDuration()
    {
        await using var db = CreateDb();
        var cmd = ValidCommand();
        var handler = new CreateEventCommandHandler(db, CacheMock());

        var result = await handler.Handle(cmd, CancellationToken.None);

        var expected = cmd.Request.StartsAt.AddMinutes(cmd.Request.DurationMinutes);
        result.ExpiresAt.Should().BeCloseTo(expected, TimeSpan.FromSeconds(1));
    }

    [Fact]
    public async Task CallsCacheRemove_AfterCreatingEvent()
    {
        await using var db = CreateDb();
        var cache = CacheMock();
        var handler = new CreateEventCommandHandler(db, cache);

        await handler.Handle(ValidCommand(), CancellationToken.None);

        await cache.Received(1).RemoveAsync(Arg.Is<string>(k => k.StartsWith("events:nearby:")));
    }

    [Fact]
    public async Task EventCreatedYesterday_DoesNotCountTowardsLimit()
    {
        await using var db = CreateDb();
        var creatorId = Guid.NewGuid();
        var yesterday = new DateTimeOffset(DateTimeOffset.UtcNow.Date.AddDays(-1), TimeSpan.Zero);

        // 2 eventos de ayer — no deben bloquear hoy
        for (var i = 0; i < 2; i++)
        {
            db.Events.Add(new Event
            {
                Id = Guid.NewGuid(),
                CreatorId = creatorId,
                Title = $"Evento ayer {i}",
                Description = "desc",
                ActionType = ActionType.Social,
                InterventionLevel = InterventionLevel.Bajo,
                Location = new Point(-3.703, 40.416) { SRID = 4326 },
                RadiusMeters = 100,
                Visibility = EventVisibility.Public,
                StartsAt = yesterday,
                ExpiresAt = yesterday.AddHours(1),
                Status = EventStatus.Active,
                CreatedAt = yesterday
            });
        }
        await db.SaveChangesAsync();

        var handler = new CreateEventCommandHandler(db, CacheMock());
        var act = () => handler.Handle(ValidCommand(creatorId), CancellationToken.None);

        await act.Should().NotThrowAsync();
    }
}
