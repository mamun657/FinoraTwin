using FinoraTwin.Domain.Abstractions;

namespace FinoraTwin.Infrastructure.Security;

public class SystemDateTime : IDateTime
{
    public DateTime UtcNow => DateTime.UtcNow;
}
