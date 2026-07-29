using Infrastructure.Geo;

namespace UnitTests.TestUtils;

public class SeededRandomSource(int seed) : IRandomSource
{
    private readonly Random _random = new(seed);
    public double NextDouble() => _random.NextDouble();
}
