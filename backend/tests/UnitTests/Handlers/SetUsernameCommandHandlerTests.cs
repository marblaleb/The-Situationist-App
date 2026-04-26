using Api.Features.Users;
using Domain;
using Domain.Entities;
using FluentAssertions;
using Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;

namespace UnitTests.Handlers;

public class SetUsernameCommandHandlerTests
{
    private static AppDbContext CreateDb() =>
        new(new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options);

    private static IConfiguration FakeConfig() =>
        new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["Jwt:PrivateKeyPem"] = null,
                ["Jwt:Issuer"] = "test",
                ["Jwt:Audience"] = "test"
            })
            .Build();

    private static User SeedUser(AppDbContext db, string? existingUsername = null)
    {
        var user = new User
        {
            Id = Guid.NewGuid(),
            ExternalId = "ext-1",
            Provider = Provider.Google,
            Email = "alice@example.com",
            Username = existingUsername,
            CreatedAt = DateTimeOffset.UtcNow,
            LastSeenAt = DateTimeOffset.UtcNow
        };
        db.Users.Add(user);
        db.SaveChanges();
        return user;
    }

    [Fact]
    public async Task SavesUsername_WhenValid()
    {
        await using var db = CreateDb();
        var user = SeedUser(db);
        var handler = new SetUsernameCommandHandler(db, FakeConfig());

        // JWT generation throws with null key — we only test DB save here.
        try { await handler.Handle(new SetUsernameCommand(user.Id, "alice_d"), CancellationToken.None); }
        catch { /* JWT generation may throw in tests */ }

        var saved = await db.Users.FindAsync(user.Id);
        saved!.Username.Should().Be("alice_d");
    }

    [Fact]
    public async Task ThrowsInvalidOperation_WhenUsernameTaken()
    {
        await using var db = CreateDb();
        SeedUser(db, existingUsername: "alice_d");
        var user2 = new User
        {
            Id = Guid.NewGuid(),
            ExternalId = "ext-2",
            Provider = Provider.Google,
            Email = "bob@example.com",
            CreatedAt = DateTimeOffset.UtcNow,
            LastSeenAt = DateTimeOffset.UtcNow
        };
        db.Users.Add(user2);
        await db.SaveChangesAsync();

        var handler = new SetUsernameCommandHandler(db, FakeConfig());

        var act = () => handler.Handle(new SetUsernameCommand(user2.Id, "alice_d"), CancellationToken.None);

        await act.Should().ThrowAsync<InvalidOperationException>()
            .WithMessage("*already taken*");
    }

    [Fact]
    public async Task ThrowsInvalidOperation_WhenUsernameTakenCaseInsensitive()
    {
        await using var db = CreateDb();
        SeedUser(db, existingUsername: "Alice_D");
        var user2 = new User
        {
            Id = Guid.NewGuid(),
            ExternalId = "ext-2",
            Provider = Provider.Google,
            Email = "bob@example.com",
            CreatedAt = DateTimeOffset.UtcNow,
            LastSeenAt = DateTimeOffset.UtcNow
        };
        db.Users.Add(user2);
        await db.SaveChangesAsync();

        var handler = new SetUsernameCommandHandler(db, FakeConfig());

        var act = () => handler.Handle(new SetUsernameCommand(user2.Id, "alice_d"), CancellationToken.None);

        await act.Should().ThrowAsync<InvalidOperationException>()
            .WithMessage("*already taken*");
    }

    [Fact]
    public async Task ThrowsInvalidOperation_WhenUserNotFound()
    {
        await using var db = CreateDb();
        var handler = new SetUsernameCommandHandler(db, FakeConfig());

        var act = () => handler.Handle(new SetUsernameCommand(Guid.NewGuid(), "alice_d"), CancellationToken.None);

        await act.Should().ThrowAsync<InvalidOperationException>()
            .WithMessage("*not found*");
    }

    [Fact]
    public async Task AllowsCurrentUser_ToKeepSameUsername()
    {
        await using var db = CreateDb();
        var user = SeedUser(db, existingUsername: "alice_d");
        var handler = new SetUsernameCommandHandler(db, FakeConfig());

        // Should not throw "already taken" — user is updating their own username.
        try { await handler.Handle(new SetUsernameCommand(user.Id, "alice_d"), CancellationToken.None); }
        catch (InvalidOperationException ex) when (ex.Message.Contains("already taken")) { throw; }
        catch { /* JWT generation may throw with null key in tests */ }

        var saved = await db.Users.FindAsync(user.Id);
        saved!.Username.Should().Be("alice_d");
    }
}
