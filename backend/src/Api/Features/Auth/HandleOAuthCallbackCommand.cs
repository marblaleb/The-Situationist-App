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

    private async Task<(string externalId, string email)> ExchangeCodeForUserInfoAsync(string provider, string code, CancellationToken ct)
    {
        // Integration point: exchange OAuth code with provider
        // In production this calls Google/Apple token endpoint
        await Task.CompletedTask;
        return (code, $"{code}@{provider}.placeholder");
    }
}
