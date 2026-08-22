namespace FinoraTwin.Domain.Entities;

public class LoanPayment
{
    public Guid Id { get; set; }
    public Guid LoanId { get; set; }
    public decimal Amount { get; set; }
    public DateTime PaidAt { get; set; }
    public string Notes { get; set; } = string.Empty;

    public Loan? Loan { get; set; }
}
