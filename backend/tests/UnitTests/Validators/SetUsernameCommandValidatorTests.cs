using Api.Features.Users;
using FluentAssertions;

namespace UnitTests.Validators;

public class SetUsernameCommandValidatorTests
{
    private readonly SetUsernameCommandValidator _validator = new();

    private SetUsernameCommand Cmd(string username) =>
        new(Guid.NewGuid(), username);

    [Fact]
    public async Task ValidUsername_PassesValidation()
    {
        var result = await _validator.ValidateAsync(Cmd("alice_d"));
        result.IsValid.Should().BeTrue();
    }

    [Theory]
    [InlineData("")]
    [InlineData("  ")]
    public async Task EmptyOrWhitespace_FailsValidation(string username)
    {
        var result = await _validator.ValidateAsync(Cmd(username));
        result.IsValid.Should().BeFalse();
        result.Errors.Should().Contain(e => e.PropertyName == "Username");
    }

    [Fact]
    public async Task TooShort_FailsValidation()
    {
        var result = await _validator.ValidateAsync(Cmd("ab"));
        result.IsValid.Should().BeFalse();
        result.Errors.Should().Contain(e => e.PropertyName == "Username");
    }

    [Fact]
    public async Task TooLong_FailsValidation()
    {
        var result = await _validator.ValidateAsync(Cmd(new string('a', 21)));
        result.IsValid.Should().BeFalse();
        result.Errors.Should().Contain(e => e.PropertyName == "Username");
    }

    [Fact]
    public async Task StartsWithDigit_FailsValidation()
    {
        var result = await _validator.ValidateAsync(Cmd("1alice"));
        result.IsValid.Should().BeFalse();
        result.Errors.Should().Contain(e => e.PropertyName == "Username");
    }

    [Fact]
    public async Task ContainsSpace_FailsValidation()
    {
        var result = await _validator.ValidateAsync(Cmd("alice doe"));
        result.IsValid.Should().BeFalse();
        result.Errors.Should().Contain(e => e.PropertyName == "Username");
    }

    [Fact]
    public async Task ContainsHyphen_FailsValidation()
    {
        var result = await _validator.ValidateAsync(Cmd("alice-doe"));
        result.IsValid.Should().BeFalse();
        result.Errors.Should().Contain(e => e.PropertyName == "Username");
    }

    [Fact]
    public async Task AtMinLength_PassesValidation()
    {
        var result = await _validator.ValidateAsync(Cmd("abc"));
        result.IsValid.Should().BeTrue();
    }

    [Fact]
    public async Task AtMaxLength_PassesValidation()
    {
        var result = await _validator.ValidateAsync(Cmd("a" + new string('b', 19))); // 20 chars
        result.IsValid.Should().BeTrue();
    }

    [Fact]
    public async Task UnderscoreAllowed()
    {
        var result = await _validator.ValidateAsync(Cmd("alice_doe_99"));
        result.IsValid.Should().BeTrue();
    }

    [Fact]
    public async Task MixedCase_PassesValidation()
    {
        var result = await _validator.ValidateAsync(Cmd("AliceDoe"));
        result.IsValid.Should().BeTrue();
    }
}
