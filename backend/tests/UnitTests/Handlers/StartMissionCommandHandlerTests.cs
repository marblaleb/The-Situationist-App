using Api.Features.Missions;
using Domain;
using Domain.Entities;
using FluentAssertions;
using Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using NetTopologySuite.Geometries;

namespace UnitTests.Handlers;

public class StartMissionCommandHandlerTests
{
    private static AppDbContext CreateDb() =>
        new(new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options);

    private static Mission ActiveMission(Guid creatorId) => new()
    {
        Id = Guid.NewGuid(),
        CreatorId = creatorId,
        Title = "Misión de prueba",
        Description = "Descripción",
        Location = new Point(-3.703, 40.416) { SRID = 4326 },
        RadiusMeters = 300,
        Status = MissionStatus.Active,
        CreatedAt = DateTimeOffset.UtcNow
    };

    private static Clue RequiredClue(Guid missionId, int order = 1) => new()
    {
        Id = Guid.NewGuid(),
        MissionId = missionId,
        Order = order,
        Type = ClueType.Textual,
        Content = "Encuentra el símbolo",
        AnswerHash = "hash",
        IsOptional = false
    };

    [Fact]
    public async Task ThrowsKeyNotFound_WhenMissionDoesNotExist()
    {
        await using var db = CreateDb();
        var handler = new StartMissionCommandHandler(db);

        var act = () => handler.Handle(
            new StartMissionCommand(Guid.NewGuid(), Guid.NewGuid()),
            CancellationToken.None);

        await act.Should().ThrowAsync<KeyNotFoundException>()
            .WithMessage("*Mission not found*");
    }

    [Theory]
    [InlineData(MissionStatus.Draft)]
    [InlineData(MissionStatus.Archived)]
    public async Task ThrowsInvalidOperation_WhenMissionIsNotActive(MissionStatus status)
    {
        await using var db = CreateDb();
        var mission = ActiveMission(Guid.NewGuid());
        mission.Status = status;
        db.Missions.Add(mission);
        await db.SaveChangesAsync();

        var handler = new StartMissionCommandHandler(db);

        var act = () => handler.Handle(
            new StartMissionCommand(mission.Id, Guid.NewGuid()),
            CancellationToken.None);

        await act.Should().ThrowAsync<InvalidOperationException>()
            .WithMessage("*not active*");
    }

    [Fact]
    public async Task ThrowsInvalidOperation_WhenCreatorTriesToStartOwnMission()
    {
        await using var db = CreateDb();
        var creatorId = Guid.NewGuid();
        var mission = ActiveMission(creatorId);
        db.Missions.Add(mission);
        db.Clues.Add(RequiredClue(mission.Id));
        await db.SaveChangesAsync();

        var handler = new StartMissionCommandHandler(db);

        var act = () => handler.Handle(
            new StartMissionCommand(mission.Id, creatorId),
            CancellationToken.None);

        await act.Should().ThrowAsync<InvalidOperationException>()
            .WithMessage("*Creator cannot start*");
    }

    [Fact]
    public async Task ThrowsInvalidOperation_WhenUserAlreadyHasActiveProgress()
    {
        await using var db = CreateDb();
        var userId = Guid.NewGuid();
        var mission = ActiveMission(Guid.NewGuid());
        var clue = RequiredClue(mission.Id);
        db.Missions.Add(mission);
        db.Clues.Add(clue);

        // progreso previo activo
        db.MissionProgresses.Add(new MissionProgress
        {
            Id = Guid.NewGuid(),
            MissionId = mission.Id,
            UserId = userId,
            CurrentClueId = clue.Id,
            StartedAt = DateTimeOffset.UtcNow,
            Status = MissionProgressStatus.InProgress
        });
        await db.SaveChangesAsync();

        var handler = new StartMissionCommandHandler(db);

        var act = () => handler.Handle(
            new StartMissionCommand(mission.Id, userId),
            CancellationToken.None);

        await act.Should().ThrowAsync<InvalidOperationException>()
            .WithMessage("*active progress*");
    }

    [Fact]
    public async Task ThrowsInvalidOperation_WhenMissionHasNoClues()
    {
        await using var db = CreateDb();
        var mission = ActiveMission(Guid.NewGuid());
        db.Missions.Add(mission);
        await db.SaveChangesAsync();

        var handler = new StartMissionCommandHandler(db);

        var act = () => handler.Handle(
            new StartMissionCommand(mission.Id, Guid.NewGuid()),
            CancellationToken.None);

        await act.Should().ThrowAsync<InvalidOperationException>()
            .WithMessage("*no clues*");
    }

    [Fact]
    public async Task CreatesProgressWithFirstNonOptionalClue()
    {
        await using var db = CreateDb();
        var mission = ActiveMission(Guid.NewGuid());
        var optionalClue = new Clue
        {
            Id = Guid.NewGuid(), MissionId = mission.Id, Order = 1,
            Type = ClueType.Textual, Content = "Opcional", AnswerHash = "h", IsOptional = true
        };
        var requiredClue = new Clue
        {
            Id = Guid.NewGuid(), MissionId = mission.Id, Order = 2,
            Type = ClueType.Textual, Content = "Obligatoria", AnswerHash = "h", IsOptional = false
        };
        db.Missions.Add(mission);
        db.Clues.AddRange(optionalClue, requiredClue);
        await db.SaveChangesAsync();

        var userId = Guid.NewGuid();
        var handler = new StartMissionCommandHandler(db);
        var result = await handler.Handle(new StartMissionCommand(mission.Id, userId), CancellationToken.None);

        result.CurrentClue.Should().NotBeNull();
        result.CurrentClue!.Id.Should().Be(requiredClue.Id);
    }

    [Fact]
    public async Task FallsBackToFirstClue_WhenAllCluesAreOptional()
    {
        await using var db = CreateDb();
        var mission = ActiveMission(Guid.NewGuid());
        var onlyClue = new Clue
        {
            Id = Guid.NewGuid(), MissionId = mission.Id, Order = 1,
            Type = ClueType.Textual, Content = "Pista", AnswerHash = "h", IsOptional = true
        };
        db.Missions.Add(mission);
        db.Clues.Add(onlyClue);
        await db.SaveChangesAsync();

        var handler = new StartMissionCommandHandler(db);
        var result = await handler.Handle(
            new StartMissionCommand(mission.Id, Guid.NewGuid()),
            CancellationToken.None);

        result.CurrentClue!.Id.Should().Be(onlyClue.Id);
    }

    [Fact]
    public async Task ReturnsMissionProgressWithInProgressStatus()
    {
        await using var db = CreateDb();
        var mission = ActiveMission(Guid.NewGuid());
        db.Missions.Add(mission);
        db.Clues.Add(RequiredClue(mission.Id));
        await db.SaveChangesAsync();

        var handler = new StartMissionCommandHandler(db);
        var result = await handler.Handle(
            new StartMissionCommand(mission.Id, Guid.NewGuid()),
            CancellationToken.None);

        result.Status.Should().Be("InProgress");
        result.MissionId.Should().Be(mission.Id);
        result.HintsUsed.Should().Be(0);
    }
}
