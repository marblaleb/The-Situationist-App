using System.Net;
using System.Text;
using FluentAssertions;
using Infrastructure.Geo;

namespace UnitTests.Geo;

public class OverpassClientTests
{
    private static HttpClient CreateClient(string poisJson, string exclusionsJson)
    {
        var handler = new FakeHttpMessageHandler(poisJson, exclusionsJson);
        return new HttpClient(handler) { BaseAddress = new Uri("https://overpass-api.de/api/") };
    }

    [Fact]
    public async Task FetchAsync_ParsesPoisFromNodesAndWayCenters()
    {
        const string poisJson = """
        {
          "elements": [
            { "type": "node", "lat": 40.42, "lon": -3.70, "tags": { "shop": "bakery" } },
            { "type": "way", "center": { "lat": 40.421, "lon": -3.701 }, "tags": { "building": "yes" } }
          ]
        }
        """;
        const string exclusionsJson = """{ "elements": [] }""";

        var client = new OverpassClient(CreateClient(poisJson, exclusionsJson));
        var result = await client.FetchAsync(40.4168, -3.7038, 2000);

        result.Pois.Should().HaveCount(2);
        result.Pois.Should().ContainEquivalentOf(new PoiPoint(40.42, -3.70));
        result.Pois.Should().ContainEquivalentOf(new PoiPoint(40.421, -3.701));
    }

    [Fact]
    public async Task FetchAsync_ParsesExclusionRingsFromWayGeometry()
    {
        const string poisJson = """{ "elements": [] }""";
        const string exclusionsJson = """
        {
          "elements": [
            {
              "type": "way",
              "tags": { "natural": "water" },
              "geometry": [
                { "lat": 40.40, "lon": -3.70 },
                { "lat": 40.41, "lon": -3.70 },
                { "lat": 40.41, "lon": -3.71 },
                { "lat": 40.40, "lon": -3.71 },
                { "lat": 40.40, "lon": -3.70 }
              ]
            }
          ]
        }
        """;

        var client = new OverpassClient(CreateClient(poisJson, exclusionsJson));
        var result = await client.FetchAsync(40.4168, -3.7038, 2000);

        result.ExclusionRings.Should().HaveCount(1);
        result.ExclusionRings[0].Points.Should().HaveCount(5);
        result.ExclusionRings[0].Points[0].Should().Be(new GeoCoordinate(40.40, -3.70));
    }

    [Fact]
    public async Task FetchAsync_FiltersNullGeometryPoints_KeepsRingWhenEnoughValidPointsRemain()
    {
        const string poisJson = """{ "elements": [] }""";
        const string exclusionsJson = """
        {
          "elements": [
            {
              "type": "way",
              "tags": { "natural": "water" },
              "geometry": [
                { "lat": 40.40, "lon": -3.70 },
                null,
                { "lat": 40.41, "lon": -3.71 },
                { "lat": 40.42, "lon": -3.72 },
                { "lat": 40.40, "lon": -3.70 }
              ]
            }
          ]
        }
        """;

        var client = new OverpassClient(CreateClient(poisJson, exclusionsJson));
        var result = await client.FetchAsync(40.4168, -3.7038, 2000);

        result.ExclusionRings.Should().HaveCount(1);
        result.ExclusionRings[0].Points.Should().HaveCount(4);
        result.ExclusionRings[0].Points.Should().NotContainNulls();
    }

    [Fact]
    public async Task FetchAsync_SkipsRing_WhenNullGeometryPointsDropBelowMinimum()
    {
        const string poisJson = """{ "elements": [] }""";
        const string exclusionsJson = """
        {
          "elements": [
            {
              "type": "way",
              "tags": { "natural": "water" },
              "geometry": [
                { "lat": 40.40, "lon": -3.70 },
                null,
                { "lat": 40.41, "lon": -3.71 }
              ]
            }
          ]
        }
        """;

        var client = new OverpassClient(CreateClient(poisJson, exclusionsJson));
        var result = await client.FetchAsync(40.4168, -3.7038, 2000);

        result.ExclusionRings.Should().BeEmpty();
    }

    [Fact]
    public async Task FetchAsync_Throws_WhenOverpassReturnsError()
    {
        var handler = new AlwaysFailingHandler(HttpStatusCode.ServiceUnavailable);
        var client = new OverpassClient(new HttpClient(handler) { BaseAddress = new Uri("https://overpass-api.de/api/") });

        var act = () => client.FetchAsync(40.4168, -3.7038, 2000);

        await act.Should().ThrowAsync<HttpRequestException>();
        // One call per query (POI + exclusions run concurrently), no retries for a non-retryable status.
        handler.CallCount.Should().Be(2);
    }

    [Fact]
    public async Task FetchAsync_RetriesOnce_WhenOverpassReturns504()
    {
        const string poisJson = """
        {
          "elements": [
            { "type": "node", "lat": 40.42, "lon": -3.70 }
          ]
        }
        """;
        const string exclusionsJson = """{ "elements": [] }""";

        var handler = new FlakyThenSucceedsHandler(poisJson, exclusionsJson);
        var client = new OverpassClient(new HttpClient(handler) { BaseAddress = new Uri("https://overpass-api.de/api/") });

        var result = await client.FetchAsync(40.4168, -3.7038, 2000);

        result.Pois.Should().ContainSingle(p => p.Lat == 40.42 && p.Lng == -3.70);
    }

    [Fact]
    public async Task FetchAsync_Throws_WhenOverpassReturns504Repeatedly()
    {
        var handler = new AlwaysFailingHandler(HttpStatusCode.GatewayTimeout);
        var client = new OverpassClient(new HttpClient(handler) { BaseAddress = new Uri("https://overpass-api.de/api/") });

        var act = () => client.FetchAsync(40.4168, -3.7038, 2000);

        await act.Should().ThrowAsync<HttpRequestException>();
    }
}

file class FakeHttpMessageHandler(string poisResponse, string exclusionsResponse) : HttpMessageHandler
{
    protected override async Task<HttpResponseMessage> SendAsync(
        HttpRequestMessage request, CancellationToken cancellationToken)
    {
        // Route by query content rather than call order: FetchAsync now fires both
        // Overpass requests concurrently, so arrival order at the handler is a race.
        var requestBody = await request.Content!.ReadAsStringAsync(cancellationToken);
        var isPoiQuery = requestBody.Contains("shop");
        var body = isPoiQuery ? poisResponse : exclusionsResponse;
        return new HttpResponseMessage(HttpStatusCode.OK)
        {
            Content = new StringContent(body, Encoding.UTF8, "application/json"),
        };
    }
}

file class AlwaysFailingHandler(HttpStatusCode statusCode) : HttpMessageHandler
{
    public int CallCount { get; private set; }

    protected override Task<HttpResponseMessage> SendAsync(
        HttpRequestMessage request, CancellationToken cancellationToken)
    {
        CallCount++;
        return Task.FromResult(new HttpResponseMessage(statusCode));
    }
}

file class FlakyThenSucceedsHandler(string poisResponse, string exclusionsResponse) : HttpMessageHandler
{
    private int _poiCallCount;

    protected override async Task<HttpResponseMessage> SendAsync(
        HttpRequestMessage request, CancellationToken cancellationToken)
    {
        var requestBody = await request.Content!.ReadAsStringAsync(cancellationToken);
        var isPoiQuery = requestBody.Contains("shop");

        if (isPoiQuery)
        {
            _poiCallCount++;
            if (_poiCallCount == 1)
                return new HttpResponseMessage(HttpStatusCode.GatewayTimeout);

            return new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = new StringContent(poisResponse, Encoding.UTF8, "application/json"),
            };
        }

        return new HttpResponseMessage(HttpStatusCode.OK)
        {
            Content = new StringContent(exclusionsResponse, Encoding.UTF8, "application/json"),
        };
    }
}
