using System.Net.Http.Json;
using System.Text.Json;

namespace Infrastructure.Ai;

public record EventContext(string ActionType, string InterventionLevel, string? UserLocation);
public record DerivaContext(string DerivaType, string TimeOfDay, string GeohashZone, string? PreviousInstruction, string Language);
public record EventDraft(string Title, string Description, string ActionType, string InterventionLevel);
public record DerivaInstructionResult(string Content);
public record ModerationResult(bool IsAllowed, string? Reason);

public interface IAnthropicClient
{
    Task<EventDraft> GenerateEventSuggestionAsync(EventContext context, CancellationToken ct = default);
    Task<DerivaInstructionResult> GenerateDerivaInstructionAsync(DerivaContext context, CancellationToken ct = default);
    Task<ModerationResult> ModerateContentAsync(string content, CancellationToken ct = default);
}

public class AnthropicClient(HttpClient httpClient) : IAnthropicClient
{
    private const string MessagesEndpoint = "v1/messages";
    private const string Model = "claude-haiku-4-5-20251001";

    public async Task<EventDraft> GenerateEventSuggestionAsync(EventContext context, CancellationToken ct = default)
    {
        var locationLine = context.UserLocation != null ? $"Zona aproximada: {context.UserLocation}" : "";
        var prompt =
            "Genera una sugerencia de evento situacionista urbano efímero.\n" +
            $"Tipo de acción: {context.ActionType}\n" +
            $"Nivel de intervención: {context.InterventionLevel}\n" +
            locationLine + "\n" +
            "Responde SOLO con JSON válido con este esquema exacto:\n" +
            "{\"title\": \"string\", \"description\": \"string (max 200 chars)\", \"actionType\": \"string\", \"interventionLevel\": \"string\"}";

        var response = await SendMessageAsync(prompt, ct);
        return JsonSerializer.Deserialize<EventDraft>(response, JsonOptions)!;
    }

    public async Task<DerivaInstructionResult> GenerateDerivaInstructionAsync(DerivaContext context, CancellationToken ct = default)
    {
        var previousLine = context.PreviousInstruction != null
            ? $"Instrucción anterior (no repetir): {context.PreviousInstruction}"
            : "";
        var prompt =
            "Eres un generador de instrucciones para una deriva situacionista urbana.\n" +
            $"Tipo de deriva: {context.DerivaType}\n" +
            $"Momento del día: {context.TimeOfDay}\n" +
            $"Zona urbana aproximada (geohash): {context.GeohashZone}\n" +
            previousLine + "\n" +
            $"Idioma: {context.Language}\n" +
            "Genera UNA instrucción corta (1-3 frases), accionable e inmediata para el usuario.\n" +
            "Responde SOLO con JSON válido: {\"content\": \"string\"}";

        var response = await SendMessageAsync(prompt, ct);
        return JsonSerializer.Deserialize<DerivaInstructionResult>(response, JsonOptions)!;
    }

    public async Task<ModerationResult> ModerateContentAsync(string content, CancellationToken ct = default)
    {
        var prompt =
            "Evalúa si el siguiente contenido es apropiado para una app de eventos urbanos situacionistas.\n" +
            "Rechaza contenido violento, discriminatorio, ilegal o dañino.\n\n" +
            $"Contenido: {content}\n\n" +
            "Responde SOLO con JSON válido: {\"isAllowed\": true/false, \"reason\": \"string o null\"}";

        var response = await SendMessageAsync(prompt, ct);
        return JsonSerializer.Deserialize<ModerationResult>(response, JsonOptions)!;
    }

    private async Task<string> SendMessageAsync(string userMessage, CancellationToken ct)
    {
        var request = new
        {
            model = Model,
            max_tokens = 512,
            messages = new[] { new { role = "user", content = userMessage } }
        };

        var httpResponse = await httpClient.PostAsJsonAsync(MessagesEndpoint, request, ct);
        if (!httpResponse.IsSuccessStatusCode)
        {
            var body = await httpResponse.Content.ReadAsStringAsync(ct);
            throw new HttpRequestException($"Anthropic API {(int)httpResponse.StatusCode}: {body}");
        }

        using var doc = await JsonDocument.ParseAsync(await httpResponse.Content.ReadAsStreamAsync(ct), cancellationToken: ct);
        return doc.RootElement
            .GetProperty("content")[0]
            .GetProperty("text")
            .GetString()!;
    }

    private static readonly JsonSerializerOptions JsonOptions = new(JsonSerializerDefaults.Web);
}
