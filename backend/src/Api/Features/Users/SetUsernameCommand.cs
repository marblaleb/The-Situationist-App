using FluentValidation;
using Infrastructure.Persistence;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using System.Text.RegularExpressions;

namespace Api.Features.Users;

public record SetUsernameCommand(Guid UserId, string Username) : IRequest<SetUsernameResponse>;
public record SetUsernameResponse(string AccessToken);

public class SetUsernameCommandValidator : AbstractValidator<SetUsernameCommand>
{
    private static readonly Regex UsernameRegex =
        new(@"^[a-zA-Z][a-zA-Z0-9_]{2,19}$", RegexOptions.Compiled);

    public SetUsernameCommandValidator()
    {
        RuleFor(x => x.Username)
            .NotEmpty()
            .Must(u => UsernameRegex.IsMatch(u.Trim()))
            .WithMessage("Username must be 3–20 characters, start with a letter, and contain only letters, numbers, or underscores.");
    }
}

public class SetUsernameCommandHandler(AppDbContext db, IConfiguration config)
    : IRequestHandler<SetUsernameCommand, SetUsernameResponse>
{
    public async Task<SetUsernameResponse> Handle(SetUsernameCommand request, CancellationToken ct)
    {
        var user = await db.Users.FindAsync([request.UserId], ct)
            ?? throw new InvalidOperationException("User not found");

        var lowerNew = request.Username.ToLower();
        var taken = await db.Users.AnyAsync(
            u => u.Id != request.UserId && u.Username != null && u.Username.ToLower() == lowerNew,
            ct);
        if (taken) throw new InvalidOperationException("Username already taken");

        user.Username = request.Username;
        await db.SaveChangesAsync(ct);

        var token = Api.Features.Auth.JwtHelper.GenerateJwt(user, config);
        return new SetUsernameResponse(token);
    }
}
