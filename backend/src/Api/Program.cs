using Api.Features.Auth;
using Api.Features.Chat;
using Api.Features.Deriva;
using Api.Features.Events;
using Api.Features.Missions;
using Api.Features.Profile;
using FluentValidation;
using Microsoft.AspNetCore.HttpOverrides;
using Infrastructure;
using Infrastructure.Cache;
using Microsoft.EntityFrameworkCore;
using Infrastructure.SignalR;
using MediatR;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.IdentityModel.Tokens;
using System.Security.Cryptography;
using System.Threading.RateLimiting;

var builder = WebApplication.CreateBuilder(args);

// CORS — allow Flutter web and local dev origins
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        if (builder.Environment.IsDevelopment())
            policy.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod();
        else
            policy.WithOrigins("https://situationist.app", "https://app.situationist.app", "https://the-situationist-7c23f.web.app", "https://the-situationist-7c23f.firebaseapp.com")
                  .AllowAnyHeader().AllowAnyMethod().AllowCredentials();
    });
});

// Infrastructure (EF Core, Redis, Anthropic client, background workers)
builder.Services.AddInfrastructure(builder.Configuration);

// MediatR — scan Api assembly for handlers
builder.Services.AddMediatR(cfg => cfg.RegisterServicesFromAssembly(typeof(Program).Assembly));

// FluentValidation
builder.Services.AddValidatorsFromAssembly(typeof(Program).Assembly);

// JWT Bearer (RS256)
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        // Keep JWT claim names as-is (don't remap "sub" → ClaimTypes.NameIdentifier)
        options.MapInboundClaims = false;

        var publicKeyPem = NormalizePem(builder.Configuration["Jwt:PublicKeyPem"]
            ?? throw new InvalidOperationException("Jwt:PublicKeyPem not configured"));
        var rsa = RSA.Create();
        rsa.ImportFromPem(publicKeyPem);

        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidateAudience = true,
            ValidAudience = builder.Configuration["Jwt:Audience"],
            ValidateLifetime = true,
            IssuerSigningKey = new RsaSecurityKey(rsa),
            ValidAlgorithms = [SecurityAlgorithms.RsaSha256]
        };

        // Support JWT as query param for SignalR
        options.Events = new JwtBearerEvents
        {
            OnMessageReceived = ctx =>
            {
                var token = ctx.Request.Query["access_token"];
                if (!string.IsNullOrEmpty(token) && ctx.Request.Path.StartsWithSegments("/hubs"))
                    ctx.Token = token;
                return Task.CompletedTask;
            },
            OnTokenValidated = async ctx =>
            {
                // Check JWT blacklist — fail-open if Redis is unavailable
                var jti = ctx.Principal?.FindFirst("jti")?.Value;
                if (jti is not null)
                {
                    try
                    {
                        var cache = ctx.HttpContext.RequestServices.GetRequiredService<IRedisCacheService>();
                        if (await cache.ExistsAsync($"auth:blacklist:{jti}"))
                            ctx.Fail("Token has been revoked");
                    }
                    catch
                    {
                        // Redis unavailable — allow request through rather than blocking all users
                    }
                }
            }
        };
    });

builder.Services.AddAuthorization();

// SignalR
builder.Services.AddSignalR();

// Rate limiting
var maxAiRpm = builder.Configuration.GetValue<int>("Ai:MaxRequestsPerMinute", 20);
builder.Services.AddRateLimiter(options =>
{
    options.AddSlidingWindowLimiter("ai", o =>
    {
        o.PermitLimit = maxAiRpm;
        o.Window = TimeSpan.FromMinutes(1);
        o.SegmentsPerWindow = 4;
        o.QueueProcessingOrder = QueueProcessingOrder.OldestFirst;
        o.QueueLimit = 0;
    });
});

// HttpClient factory (needed by Auth handler for OAuth exchange)
builder.Services.AddHttpClient();

// ProblemDetails (RFC 7807)
builder.Services.AddProblemDetails();

var app = builder.Build();

// Apply pending migrations + seed on startup
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<Infrastructure.Persistence.AppDbContext>();
    await db.Database.MigrateAsync();

    if (app.Environment.IsDevelopment())
    {
        var seederLogger = scope.ServiceProvider
            .GetRequiredService<ILogger<Infrastructure.Persistence.AppDbContext>>();
        await Infrastructure.Persistence.DataSeeder.SeedAsync(db, seederLogger);
    }
}

// Render terminates SSL at the load balancer — trust forwarded headers instead of redirecting
app.UseForwardedHeaders(new ForwardedHeadersOptions
{
    ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto
});
app.UseCors();
app.UseExceptionHandler();
app.UseRateLimiter();
app.UseAuthentication();
app.UseAuthorization();

// Map endpoints
app.MapGet("/health", () => Results.Ok(new { status = "ok" }));
app.MapAuthEndpoints();
app.MapEventEndpoints();
app.MapDerivaEndpoints();
app.MapMissionEndpoints();
app.MapProfileEndpoints();
app.MapChatEndpoints();

// SignalR hub
app.MapHub<EventHub>("/hubs/events");

app.Run();

static string NormalizePem(string pem) =>
    pem.Trim()          // leading/trailing whitespace
       .Trim('"')       // surrounding quotes pasted from .env file
       .Replace("\\n", "\n")   // literal \n (Render dashboard encoding)
       .Replace("\r\n", "\n")  // Windows CRLF
       .Trim();
