using Domain;
using Domain.Entities;
using FluentValidation;
using Infrastructure.Persistence;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;

namespace Api.Features.Auth;

public record HandleOAuthCallbackCommand(string Provider, string Code) : IRequest<AuthResponse>;

public class HandleOAuthCallbackCommandValidator : AbstractValidator<HandleOAuthCallbackCommand>
{
    public HandleOAuthCallbackCommandValidator()
    {
        RuleFor(x => x.Provider).Must(p => p == "google" || p == "apple").WithMessage("Invalid provider");
        RuleFor(x => x.Code).NotEmpty();
    }
}

public class HandleOAuthCallbackCommandHandler(
    AppDbContext db,
    IConfiguration config,
    IHttpClientFactory httpClientFactory) : IRequestHandler<HandleOAuthCallbackCommand, AuthResponse>
{
    public async Task<AuthResponse> Handle(HandleOAuthCallbackCommand request, CancellationToken ct)
    {
        var (externalId, email) = await ExchangeCodeForUserInfoAsync(request.Provider, request.Code, ct);

        var provider = request.Provider == "google" ? Provider.Google : Provider.Apple;

        var user = await db.Users.FirstOrDefaultAsync(u => u.ExternalId == externalId && u.Provider == provider, ct);
        var now = DateTimeOffset.UtcNow;

        if (user is null)
        {
            user = new User
            {
                Id = Guid.NewGuid(),
                ExternalId = externalId,
                Provider = provider,
                Email = email,
                CreatedAt = now,
                LastSeenAt = now
            };
            db.Users.Add(user);
        }
        else
        {
            user.LastSeenAt = now;
        }

        await db.SaveChangesAsync(ct);

        var token = JwtHelper.GenerateJwt(user, config);
        return new AuthResponse(token, "Bearer", 604800, new UserDto(user.Id, user.Email, user.Provider.ToString(), user.Username ?? string.Empty));
    }

    private async Task<(string externalId, string email)> ExchangeCodeForUserInfoAsync(
        string provider, string code, CancellationToken ct)
    {
        if (provider == "google")
        {
            var clientId     = config["OAuth:Google:ClientId"]!;
            var clientSecret = config["OAuth:Google:ClientSecret"]!;
            var redirectUri  = config["OAuth:Google:RedirectUri"]!;

            var client = httpClientFactory.CreateClient();

            // Exchange authorization code for tokens
            var tokenResponse = await client.PostAsync(
                "https://oauth2.googleapis.com/token",
                new FormUrlEncodedContent(new Dictionary<string, string>
                {
                    ["code"]          = code,
                    ["client_id"]     = clientId,
                    ["client_secret"] = clientSecret,
                    ["redirect_uri"]  = redirectUri,
                    ["grant_type"]    = "authorization_code",
                }),
                ct);

            tokenResponse.EnsureSuccessStatusCode();

            using var tokenDoc = await JsonDocument.ParseAsync(
                await tokenResponse.Content.ReadAsStreamAsync(ct), cancellationToken: ct);

            // Decode the ID token payload (middle segment) to read sub + email
            var idToken = tokenDoc.RootElement.GetProperty("id_token").GetString()!;
            var payload = idToken.Split('.')[1];
            var padded  = payload.PadRight(payload.Length + (4 - payload.Length % 4) % 4, '=');
            var json    = Encoding.UTF8.GetString(Convert.FromBase64String(padded));

            using var claims = JsonDocument.Parse(json);
            var sub   = claims.RootElement.GetProperty("sub").GetString()!;
            var email = claims.RootElement.GetProperty("email").GetString()!;

            return (sub, email);
        }

        throw new NotSupportedException($"Provider '{provider}' is not yet implemented");
    }
}
