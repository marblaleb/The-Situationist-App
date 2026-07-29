using FluentAssertions;
using Infrastructure.Geo;

namespace UnitTests.Geo;

public class RandomSourceTests
{
    [Fact]
    public void NextDouble_ReturnsValuesWithinUnitRange()
    {
        var source = new CryptoRandomSource();
        for (var i = 0; i < 1000; i++)
        {
            var value = source.NextDouble();
            value.Should().BeGreaterThanOrEqualTo(0).And.BeLessThan(1);
        }
    }

    [Fact]
    public void NextDouble_IsNotConstant()
    {
        var source = new CryptoRandomSource();
        var values = Enumerable.Range(0, 20).Select(_ => source.NextDouble()).Distinct().ToList();
        values.Count.Should().BeGreaterThan(1);
    }
}
