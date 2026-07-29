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
        var handler = new FailingHttpMessageHandler();
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

file class FailingHttpMessageHandler : HttpMessageHandler
{
    protected override Task<HttpResponseMessage> SendAsync(
        HttpRequestMessage request, CancellationToken cancellationToken)
        => Task.FromResult(new HttpResponseMessage(HttpStatusCode.ServiceUnavailable));
}
