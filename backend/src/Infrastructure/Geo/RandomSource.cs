using System.Security.Cryptography;

namespace Infrastructure.Geo;

public interface IRandomSource
{
    double NextDouble();
}

public class CryptoRandomSource : IRandomSource
{
    public double NextDouble()
    {
        Span<byte> bytes = stackalloc byte[8];
        RandomNumberGenerator.Fill(bytes);
        var value = BitConverter.ToUInt64(bytes) >> 11;
        return value / (double)(1UL << 53);
    }
}
