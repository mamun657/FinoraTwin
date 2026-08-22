namespace FinoraTwin.Domain.Entities;

public class Loan
{
    public Guid Id { get; set; }
    public Guid BusinessId { get; set; }
    public string Lender { get; set; } = string.Empty;
    public decimal Principal { get; set; }
    public decimal AnnualInterestRate { get; set; }
    public int TermMonths { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public Business? Business { get; set; }
    public ICollection<LoanPayment> Payments { get; set; } = new List<LoanPayment>();
}
