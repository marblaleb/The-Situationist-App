using Infrastructure.Persistence;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Api.Features.Auth;

public record GetCurrentUserQuery(Guid UserId) : IRequest<UserDto?>;

public class GetCurrentUserQueryHandler(AppDbContext db) : IRequestHandler<GetCurrentUserQuery, UserDto?>
{
    public async Task<UserDto?> Handle(GetCurrentUserQuery request, CancellationToken ct)
    {
        var user = await db.Users.FirstOrDefaultAsync(u => u.Id == request.UserId, ct);
        if (user is null) return null;
        return new UserDto(user.Id, user.Email, user.Provider.ToString());
    }
}
