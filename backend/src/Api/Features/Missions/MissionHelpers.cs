namespace Api.Features.Missions;

internal static class MissionHelpers
{
    internal static ClueResponse MapClue(Domain.Entities.Clue c) => new(
        c.Id, c.Order, c.Type.ToString(), c.Content,
        c.Hint is not null, c.IsOptional,
        c.Location?.Y, c.Location?.X);
}
