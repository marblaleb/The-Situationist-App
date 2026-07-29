using System.Globalization;
using System.Text.Json;

namespace Infrastructure.Geo;

public interface IOverpassClient
{
    Task<OverpassResult> FetchAsync(double lat, double lng, int radiusMeters, CancellationToken ct = default);
}

public class OverpassClient(HttpClient httpClient) : IOverpassClient
{
    private static readonly JsonSerializerOptions JsonOptions = new(JsonSerializerDefaults.Web);

    public async Task<OverpassResult> FetchAsync(double lat, double lng, int radiusMeters, CancellationToken ct = default)
    {
        var pois = await FetchPoisAsync(lat, lng, radiusMeters, ct);
        var exclusions = await FetchExclusionsAsync(lat, lng, radiusMeters, ct);
        return new OverpassResult(pois, exclusions);
    }

    private async Task<IReadOnlyList<PoiPoint>> FetchPoisAsync(double lat, double lng, int radiusMeters, CancellationToken ct)
    {
        var latStr = lat.ToString(CultureInfo.InvariantCulture);
        var lngStr = lng.ToString(CultureInfo.InvariantCulture);
        var query = $$"""
        [out:json][timeout:25];
        (
          node["shop"](around:{{radiusMeters}},{{latStr}},{{lngStr}});
          node["amenity"](around:{{radiusMeters}},{{latStr}},{{lngStr}});
          way["building"](around:{{radiusMeters}},{{latStr}},{{lngStr}});
        );
        out center;
        """;

        var response = await SendQueryAsync(query, ct);
        var pois = new List<PoiPoint>();
        foreach (var element in response.Elements)
        {
            if (element.Type == "node" && element.Lat is not null && element.Lon is not null)
                pois.Add(new PoiPoint(element.Lat.Value, element.Lon.Value));
            else if (element.Type == "way" && element.Center is not null)
                pois.Add(new PoiPoint(element.Center.Lat, element.Center.Lon));
        }
        return pois;
    }

    private async Task<IReadOnlyList<ExclusionRing>> FetchExclusionsAsync(double lat, double lng, int radiusMeters, CancellationToken ct)
    {
        var latStr = lat.ToString(CultureInfo.InvariantCulture);
        var lngStr = lng.ToString(CultureInfo.InvariantCulture);
        var query = $$"""
        [out:json][timeout:25];
        (
          way["natural"="water"](around:{{radiusMeters}},{{latStr}},{{lngStr}});
          way["landuse"="military"](around:{{radiusMeters}},{{latStr}},{{lngStr}});
          way["leisure"="nature_reserve"](around:{{radiusMeters}},{{latStr}},{{lngStr}});
          way["boundary"="protected_area"](around:{{radiusMeters}},{{latStr}},{{lngStr}});
          way["building"]["access"~"^(private|no)$"](around:{{radiusMeters}},{{latStr}},{{lngStr}});
        );
        out geom;
        """;

        var response = await SendQueryAsync(query, ct);
        var rings = new List<ExclusionRing>();
        foreach (var element in response.Elements)
        {
            if (element.Type != "way" || element.Geometry is null || element.Geometry.Count < 3)
                continue;
            var points = element.Geometry.Select(g => new GeoCoordinate(g.Lat, g.Lon)).ToList();
            rings.Add(new ExclusionRing(points));
        }
        return rings;
    }

    private async Task<OverpassResponse> SendQueryAsync(string query, CancellationToken ct)
    {
        var content = new FormUrlEncodedContent(new Dictionary<string, string> { ["data"] = query });
        var httpResponse = await httpClient.PostAsync("interpreter", content, ct);
        if (!httpResponse.IsSuccessStatusCode)
            throw new HttpRequestException($"Overpass API {(int)httpResponse.StatusCode}");

        var stream = await httpResponse.Content.ReadAsStreamAsync(ct);
        var result = await JsonSerializer.DeserializeAsync<OverpassResponse>(stream, JsonOptions, ct);
        return result ?? new OverpassResponse([]);
    }

    private record OverpassResponse(List<OverpassElement> Elements);
    private record OverpassElement(
        string Type,
        double? Lat,
        double? Lon,
        OverpassCenter? Center,
        List<OverpassGeometryPoint>? Geometry);
    private record OverpassCenter(double Lat, double Lon);
    private record OverpassGeometryPoint(double Lat, double Lon);
}
