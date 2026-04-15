using BCrypt.Net;
using Domain;
using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using NetTopologySuite.Geometries;

namespace Infrastructure.Persistence;

/// <summary>
/// Seeds the database with realistic test data (Madrid locations).
/// Only runs when the database is empty. Safe to call on every startup.
/// </summary>
public static class DataSeeder
{
    private static readonly GeometryFactory Gf =
        new GeometryFactory(new PrecisionModel(), 4326);

    public static async Task SeedAsync(AppDbContext db, ILogger logger)
    {
        if (await db.Users.AnyAsync())
        {
            logger.LogInformation("Database already seeded — skipping.");
            return;
        }

        logger.LogInformation("Seeding database with test data…");

        // ── Users ────────────────────────────────────────────────────────────
        var now = DateTimeOffset.UtcNow;

        var alice = new User
        {
            Id = Guid.Parse("00000000-0000-0000-0000-000000000001"),
            ExternalId = "google-alice-001",
            Provider = Provider.Google,
            Email = "alice@situationist.test",
            CreatedAt = now.AddDays(-30),
            LastSeenAt = now.AddHours(-1),
        };
        var bob = new User
        {
            Id = Guid.Parse("00000000-0000-0000-0000-000000000002"),
            ExternalId = "google-bob-002",
            Provider = Provider.Google,
            Email = "bob@situationist.test",
            CreatedAt = now.AddDays(-14),
            LastSeenAt = now.AddHours(-3),
        };
        var cara = new User
        {
            Id = Guid.Parse("00000000-0000-0000-0000-000000000003"),
            ExternalId = "google-cara-003",
            Provider = Provider.Google,
            Email = "cara@situationist.test",
            CreatedAt = now.AddDays(-7),
            LastSeenAt = now.AddMinutes(-20),
        };

        db.Users.AddRange(alice, bob, cara);

        // ── Events (Madrid) ──────────────────────────────────────────────────

        // 1. Puerta del Sol — active, expiring soon
        var evSol = new Event
        {
            Id = Guid.NewGuid(),
            CreatorId = alice.Id,
            Title = "Sonido de medianoche",
            Description = "Encuentra una superficie metálica en la plaza y golpéala tres veces. Observa las reacciones.",
            ActionType = ActionType.Sensorial,
            InterventionLevel = InterventionLevel.Bajo,
            Location = Point(-3.7038, 40.4168),
            RadiusMeters = 150,
            Visibility = EventVisibility.Public,
            MaxParticipants = 8,
            StartsAt = now.AddMinutes(-30),
            ExpiresAt = now.AddMinutes(8),   // expiring soon → amber
            Status = EventStatus.Active,
            CreatedAt = now.AddMinutes(-30),
        };

        // 2. Retiro Park — active, plenty of time
        var evRetiro = new Event
        {
            Id = Guid.NewGuid(),
            CreatorId = bob.Id,
            Title = "El extraño del banco",
            Description = "Siéntate en el banco más cercano al estanque y sonríe a la primera persona que pase sin apartar la mirada durante 5 segundos.",
            ActionType = ActionType.Social,
            InterventionLevel = InterventionLevel.Medio,
            Location = Point(-3.6844, 40.4153),
            RadiusMeters = 300,
            Visibility = EventVisibility.Public,
            MaxParticipants = null,
            StartsAt = now.AddMinutes(-10),
            ExpiresAt = now.AddMinutes(40),
            Status = EventStatus.Active,
            CreatedAt = now.AddMinutes(-10),
        };

        // 3. Lavapiés — full
        var evLavapies = new Event
        {
            Id = Guid.NewGuid(),
            CreatorId = cara.Id,
            Title = "Espejo roto",
            Description = "Sitúate frente a cualquier reflejo y permanece inmóvil 90 segundos. No te muevas aunque alguien te hable.",
            ActionType = ActionType.Poetica,
            InterventionLevel = InterventionLevel.Bajo,
            Location = Point(-3.7030, 40.4079),
            RadiusMeters = 200,
            Visibility = EventVisibility.Public,
            MaxParticipants = 3,
            StartsAt = now.AddMinutes(-20),
            ExpiresAt = now.AddMinutes(25),
            Status = EventStatus.Full,
            CreatedAt = now.AddMinutes(-20),
        };

        // 4. Malasaña — active, high intensity
        var evMalasana = new Event
        {
            Id = Guid.NewGuid(),
            CreatorId = alice.Id,
            Title = "Deriva colectiva",
            Description = "Desde la plaza de Dos de Mayo, sigue al primer desconocido que lleve algo rojo durante exactamente 3 minutos, sin que te note.",
            ActionType = ActionType.Performativa,
            InterventionLevel = InterventionLevel.Alto,
            Location = Point(-3.7047, 40.4267),
            RadiusMeters = 500,
            Visibility = EventVisibility.ByProximity,
            MaxParticipants = 5,
            StartsAt = now.AddMinutes(-5),
            ExpiresAt = now.AddMinutes(55),
            Status = EventStatus.Active,
            CreatedAt = now.AddMinutes(-5),
        };

        // 5. Gran Vía — active
        var evGranVia = new Event
        {
            Id = Guid.NewGuid(),
            CreatorId = bob.Id,
            Title = "Silencio en el ruido",
            Description = "Párate en medio de la acera más transitada que encuentres. Cierra los ojos 30 segundos. Escucha.",
            ActionType = ActionType.Sensorial,
            InterventionLevel = InterventionLevel.Medio,
            Location = Point(-3.7025, 40.4197),
            RadiusMeters = 100,
            Visibility = EventVisibility.Public,
            MaxParticipants = null,
            StartsAt = now.AddMinutes(-15),
            ExpiresAt = now.AddMinutes(30),
            Status = EventStatus.Active,
            CreatedAt = now.AddMinutes(-15),
        };

        // 6. Chueca — same location as Gran Vía to test clustering
        var evChueca = new Event
        {
            Id = Guid.NewGuid(),
            CreatorId = cara.Id,
            Title = "El número de la bestia",
            Description = "Cuenta el número de personas que llevan auriculares en un radio de 10 metros. Anota el resultado en tu mano.",
            ActionType = ActionType.Sensorial,
            InterventionLevel = InterventionLevel.Bajo,
            Location = Point(-3.7028, 40.4199),  // 30m from Gran Vía — clusters with it
            RadiusMeters = 100,
            Visibility = EventVisibility.Public,
            MaxParticipants = null,
            StartsAt = now.AddMinutes(-5),
            ExpiresAt = now.AddMinutes(50),
            Status = EventStatus.Active,
            CreatedAt = now.AddMinutes(-5),
        };

        db.Events.AddRange(evSol, evRetiro, evLavapies, evMalasana, evGranVia, evChueca);

        // ── Participations ───────────────────────────────────────────────────

        db.Participations.AddRange(
            new Participation
            {
                Id = Guid.NewGuid(), EventId = evRetiro.Id, UserId = alice.Id,
                Role = ParticipationRole.Participante, JoinedAt = now.AddMinutes(-8),
            },
            new Participation
            {
                Id = Guid.NewGuid(), EventId = evRetiro.Id, UserId = cara.Id,
                Role = ParticipationRole.Observador, JoinedAt = now.AddMinutes(-6),
            },
            new Participation
            {
                Id = Guid.NewGuid(), EventId = evLavapies.Id, UserId = alice.Id,
                Role = ParticipationRole.Participante, JoinedAt = now.AddMinutes(-18),
            },
            new Participation
            {
                Id = Guid.NewGuid(), EventId = evLavapies.Id, UserId = bob.Id,
                Role = ParticipationRole.Participante, JoinedAt = now.AddMinutes(-17),
            },
            new Participation
            {
                Id = Guid.NewGuid(), EventId = evLavapies.Id, UserId = cara.Id,
                Role = ParticipationRole.Participante, JoinedAt = now.AddMinutes(-15),
            }
        );

        // ── Missions ─────────────────────────────────────────────────────────

        // Mission 1: El mapa olvidado (La Latina area) — 3 clues
        var mission1 = new Mission
        {
            Id = Guid.NewGuid(),
            CreatorId = alice.Id,
            Title = "El mapa olvidado",
            Description = "Alguien dejó instrucciones ocultas en el barrio de La Latina. Encuéntralas siguiendo las pistas.",
            Location = Point(-3.7121, 40.4124),
            RadiusMeters = 600,
            Status = MissionStatus.Active,
            CreatedAt = now.AddDays(-5),
        };

        var m1c1 = new Clue
        {
            Id = Guid.NewGuid(), MissionId = mission1.Id, Order = 1,
            Type = ClueType.Textual,
            Content = "El punto de inicio es donde el agua se detiene pero no desaparece. Busca en La Latina.",
            Hint = "Piensa en los espacios públicos donde el agua tiene presencia permanente.",
            AnswerHash = BCrypt.Net.BCrypt.HashPassword("fuente"),
            IsOptional = false,
        };
        var m1c2 = new Clue
        {
            Id = Guid.NewGuid(), MissionId = mission1.Id, Order = 2,
            Type = ClueType.Sensorial,
            Content = "Desde la fuente, camina hacia el olor más intenso del barrio. ¿Qué encuentras?",
            Hint = "Los mercados tradicionales tienen olores inconfundibles.",
            AnswerHash = BCrypt.Net.BCrypt.HashPassword("mercado"),
            IsOptional = false,
        };
        var m1c3 = new Clue
        {
            Id = Guid.NewGuid(), MissionId = mission1.Id, Order = 3,
            Type = ClueType.Contextual,
            Content = "En el mercado, localiza el puesto más antiguo. ¿Qué número tiene?",
            Hint = null,
            AnswerHash = BCrypt.Net.BCrypt.HashPassword("uno"),
            IsOptional = true,
        };

        mission1.Clues = [m1c1, m1c2, m1c3];

        // Mission 2: Voces del metro (Chamberí area) — 4 clues
        var mission2 = new Mission
        {
            Id = Guid.NewGuid(),
            CreatorId = bob.Id,
            Title = "Voces del metro",
            Description = "Una secuencia de señales auditivas y visuales escondidas en el sistema de transporte. Empieza en Chamberí.",
            Location = Point(-3.7019, 40.4345),
            RadiusMeters = 800,
            Status = MissionStatus.Active,
            CreatedAt = now.AddDays(-2),
        };

        var m2c1 = new Clue
        {
            Id = Guid.NewGuid(), MissionId = mission2.Id, Order = 1,
            Type = ClueType.Textual,
            Content = "Busca la estación fantasma de Madrid. ¿Cómo se llama la línea que la ignora?",
            Hint = "Las líneas de metro tienen colores. La que pasa por Chamberí sin detenerse tiene un color cálido.",
            AnswerHash = BCrypt.Net.BCrypt.HashPassword("dos"),
            IsOptional = false,
        };
        var m2c2 = new Clue
        {
            Id = Guid.NewGuid(), MissionId = mission2.Id, Order = 2,
            Type = ClueType.Sensorial,
            Content = "En el andén más cercano, espera el próximo tren. Cuenta los vagones en voz baja. ¿Cuántos son?",
            Hint = null,
            AnswerHash = BCrypt.Net.BCrypt.HashPassword("seis"),
            IsOptional = false,
        };
        var m2c3 = new Clue
        {
            Id = Guid.NewGuid(), MissionId = mission2.Id, Order = 3,
            Type = ClueType.Contextual,
            Content = "Busca el azulejo más viejo del vestíbulo de la estación. ¿Qué animal aparece en él?",
            Hint = "Los mosaicos del metro clásico de Madrid tienen motivos naturales.",
            AnswerHash = BCrypt.Net.BCrypt.HashPassword("oso"),
            IsOptional = false,
        };
        var m2c4 = new Clue
        {
            Id = Guid.NewGuid(), MissionId = mission2.Id, Order = 4,
            Type = ClueType.Textual,
            Content = "El oso y el madroño. ¿En qué plaza de Madrid aparece representado este símbolo de la ciudad?",
            Hint = null,
            AnswerHash = BCrypt.Net.BCrypt.HashPassword("sol"),
            IsOptional = false,
        };

        mission2.Clues = [m2c1, m2c2, m2c3, m2c4];

        // Mission 3: La ciudad de los espejos (Retiro area) — 3 clues, simpler
        var mission3 = new Mission
        {
            Id = Guid.NewGuid(),
            CreatorId = cara.Id,
            Title = "La ciudad de los espejos",
            Description = "Madrid tiene reflejos que la mayoría ignora. Esta misión es para quienes saben mirar.",
            Location = Point(-3.6844, 40.4153),
            RadiusMeters = 500,
            Status = MissionStatus.Active,
            CreatedAt = now.AddDays(-1),
        };

        var m3c1 = new Clue
        {
            Id = Guid.NewGuid(), MissionId = mission3.Id, Order = 1,
            Type = ClueType.Sensorial,
            Content = "Entra al Retiro y busca la superficie más grande que refleje el cielo sin ser una ventana. ¿Qué es?",
            Hint = "No es cristal, no es metal. Es agua.",
            AnswerHash = BCrypt.Net.BCrypt.HashPassword("estanque"),
            IsOptional = false,
        };
        var m3c2 = new Clue
        {
            Id = Guid.NewGuid(), MissionId = mission3.Id, Order = 2,
            Type = ClueType.Textual,
            Content = "En el estanque hay una figura solitaria sobre el agua. ¿A quién representa el monumento central?",
            Hint = "Es un rey, pero también es el nombre de un asteroide.",
            AnswerHash = BCrypt.Net.BCrypt.HashPassword("alfonso"),
            IsOptional = false,
        };
        var m3c3 = new Clue
        {
            Id = Guid.NewGuid(), MissionId = mission3.Id, Order = 3,
            Type = ClueType.Contextual,
            Content = "Cuenta los leones que custodian el monumento. ¿Cuántos hay?",
            Hint = null,
            AnswerHash = BCrypt.Net.BCrypt.HashPassword("cuatro"),
            IsOptional = false,
        };

        mission3.Clues = [m3c1, m3c2, m3c3];

        db.Missions.AddRange(mission1, mission2, mission3);
        db.Clues.AddRange(m1c1, m1c2, m1c3, m2c1, m2c2, m2c3, m2c4, m3c1, m3c2, m3c3);

        // ── Activity log ─────────────────────────────────────────────────────

        db.ActivityLogs.AddRange(
            new ActivityLog
            {
                Id = Guid.NewGuid(), UserId = alice.Id,
                Type = ActivityLogType.EventParticipation,
                ReferenceId = evRetiro.Id,
                OccurredAt = now.AddMinutes(-8),
                Metadata = System.Text.Json.JsonDocument.Parse("{}"),
            },
            new ActivityLog
            {
                Id = Guid.NewGuid(), UserId = alice.Id,
                Type = ActivityLogType.EventParticipation,
                ReferenceId = evLavapies.Id,
                OccurredAt = now.AddMinutes(-18),
                Metadata = System.Text.Json.JsonDocument.Parse("{}"),
            },
            new ActivityLog
            {
                Id = Guid.NewGuid(), UserId = bob.Id,
                Type = ActivityLogType.EventParticipation,
                ReferenceId = evLavapies.Id,
                OccurredAt = now.AddMinutes(-17),
                Metadata = System.Text.Json.JsonDocument.Parse("{}"),
            }
        );

        await db.SaveChangesAsync();
        logger.LogInformation(
            "Seed complete: {Users} users, {Events} events, {Missions} missions.",
            3, 6, 3);
    }

    private static Point Point(double lng, double lat) =>
        Gf.CreatePoint(new Coordinate(lng, lat));
}
