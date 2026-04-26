using Infrastructure.Persistence;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Api.Features.Users;

public record CheckUsernameAvailabilityQuery(string Username) : IRequest<bool>;

public class CheckUsernameAvailabilityQueryHandler(AppDbContext db)
    : IRequestHandler<CheckUsernameAvailabilityQuery, bool>
{
    public async Task<bool> Handle(CheckUsernameAvailabilityQuery request, CancellationToken ct)
    {
        var lower = request.Username.ToLower();
        var taken = await db.Users.AnyAsync(
            u => u.Username != null && u.Username.ToLower() == lower, ct);
        return !taken;
    }
}
