using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using System.Text.Json;

namespace Infrastructure.Persistence;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<User> Users => Set<User>();
    public DbSet<Event> Events => Set<Event>();
    public DbSet<Participation> Participations => Set<Participation>();
    public DbSet<DerivaSession> DerivaSessions => Set<DerivaSession>();
    public DbSet<DerivaInstruction> DerivaInstructions => Set<DerivaInstruction>();
    public DbSet<Mission> Missions => Set<Mission>();
    public DbSet<Clue> Clues => Set<Clue>();
    public DbSet<MissionProgress> MissionProgresses => Set<MissionProgress>();
    public DbSet<ActivityLog> ActivityLogs => Set<ActivityLog>();
    public DbSet<ChatMessage> ChatMessages => Set<ChatMessage>();

    private static JsonDocument ParseJson(string v) => JsonDocument.Parse(v);

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasPostgresExtension("postgis");

        // User
        modelBuilder.Entity<User>(e =>
        {
            e.HasKey(x => x.Id);
            e.HasIndex(x => new { x.ExternalId, x.Provider }).IsUnique();
            e.Property(x => x.Provider).HasConversion<string>();
            // Unique partial index — NULL excluded so rows without a username don't conflict.
            // Application code enforces case-insensitive uniqueness before this index fires.
            e.HasIndex(x => x.Username).IsUnique().HasFilter("\"Username\" IS NOT NULL");
        });

        // Event
        modelBuilder.Entity<Event>(e =>
        {
            e.HasKey(x => x.Id);
            e.Property(x => x.ActionType).HasConversion<string>();
            e.Property(x => x.InterventionLevel).HasConversion<string>();
            e.Property(x => x.Visibility).HasConversion<string>();
            e.Property(x => x.Status).HasConversion<string>();
            e.Property(x => x.Location).HasColumnType("geometry(Point,4326)");
            e.HasIndex(x => x.Location).HasMethod("GIST");
            e.HasOne(x => x.Creator).WithMany().HasForeignKey(x => x.CreatorId).OnDelete(DeleteBehavior.Restrict);
        });

        // Participation
        modelBuilder.Entity<Participation>(e =>
        {
            e.HasKey(x => x.Id);
            e.Property(x => x.Role).HasConversion<string>();
            e.HasIndex(x => new { x.EventId, x.UserId }).IsUnique();
            e.HasOne(x => x.Event).WithMany(x => x.Participations).HasForeignKey(x => x.EventId);
            e.HasOne(x => x.User).WithMany().HasForeignKey(x => x.UserId).OnDelete(DeleteBehavior.Restrict);
        });

        // DerivaSession
        modelBuilder.Entity<DerivaSession>(e =>
        {
            e.HasKey(x => x.Id);
            e.Property(x => x.Type).HasConversion<string>();
            e.Property(x => x.Status).HasConversion<string>();
            e.HasOne(x => x.User).WithMany().HasForeignKey(x => x.UserId).OnDelete(DeleteBehavior.Restrict);
        });

        // DerivaInstruction
        modelBuilder.Entity<DerivaInstruction>(e =>
        {
            e.HasKey(x => x.Id);
            e.Property(x => x.ContextSnapshot)
                .HasColumnType("jsonb")
                .HasConversion(
                    v => v.RootElement.GetRawText(),
                    v => ParseJson(v));
            e.HasOne(x => x.Session).WithMany(x => x.Instructions).HasForeignKey(x => x.SessionId);
        });

        // Mission
        modelBuilder.Entity<Mission>(e =>
        {
            e.HasKey(x => x.Id);
            e.Property(x => x.Status).HasConversion<string>();
            e.Property(x => x.Location).HasColumnType("geometry(Point,4326)");
            e.HasIndex(x => x.Location).HasMethod("GIST");
            e.HasOne(x => x.Creator).WithMany().HasForeignKey(x => x.CreatorId).OnDelete(DeleteBehavior.Restrict);
        });

        // Clue
        modelBuilder.Entity<Clue>(e =>
        {
            e.HasKey(x => x.Id);
            e.Property(x => x.Type).HasConversion<string>();
            e.Property(x => x.Location).HasColumnType("geometry(Point,4326)");
            e.HasOne(x => x.Mission).WithMany(x => x.Clues).HasForeignKey(x => x.MissionId);
        });

        // MissionProgress
        modelBuilder.Entity<MissionProgress>(e =>
        {
            e.HasKey(x => x.Id);
            e.Property(x => x.Status).HasConversion<string>();
            e.HasIndex(x => new { x.MissionId, x.UserId, x.Status });
            e.HasOne(x => x.Mission).WithMany().HasForeignKey(x => x.MissionId).OnDelete(DeleteBehavior.Restrict);
            e.HasOne(x => x.User).WithMany().HasForeignKey(x => x.UserId).OnDelete(DeleteBehavior.Restrict);
            e.HasOne(x => x.CurrentClue).WithMany().HasForeignKey(x => x.CurrentClueId).OnDelete(DeleteBehavior.Restrict);
        });

        // ActivityLog
        modelBuilder.Entity<ActivityLog>(e =>
        {
            e.HasKey(x => x.Id);
            e.Property(x => x.Type).HasConversion<string>();
            e.Property(x => x.Metadata)
                .HasColumnType("jsonb")
                .HasConversion(
                    v => v.RootElement.GetRawText(),
                    v => ParseJson(v));
            e.HasIndex(x => new { x.UserId, x.OccurredAt });
            e.HasOne(x => x.User).WithMany().HasForeignKey(x => x.UserId).OnDelete(DeleteBehavior.Restrict);
        });

        // ChatMessage
        modelBuilder.Entity<ChatMessage>(e =>
        {
            e.HasKey(x => x.Id);
            e.HasIndex(x => new { x.EventId, x.SentAt });
            e.HasOne(x => x.Event).WithMany().HasForeignKey(x => x.EventId).OnDelete(DeleteBehavior.Cascade);
            e.HasOne(x => x.Sender).WithMany().HasForeignKey(x => x.SenderId).OnDelete(DeleteBehavior.Restrict);
        });
    }
}
