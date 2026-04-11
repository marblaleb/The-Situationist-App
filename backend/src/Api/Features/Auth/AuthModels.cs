namespace Api.Features.Auth;

public record OAuthCallbackRequest(string Code, string State);
public record AuthResponse(string AccessToken, string TokenType, int ExpiresIn, UserDto User);
public record UserDto(Guid UserId, string Email, string Provider);
