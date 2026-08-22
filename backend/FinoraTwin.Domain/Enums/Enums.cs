namespace FinoraTwin.Domain.Enums;

public enum TransactionType
{
    Income = 0,
    Expense = 1
}

public enum TransactionCategory
{
    Sales = 0,
    Inventory = 1,
    Salary = 2,
    Rent = 3,
    Utilities = 4,
    Transport = 5,
    Marketing = 6,
    Supplier = 7,
    LoanPayment = 8,
    Services = 10,
    Subscriptions = 11,
    Other = 9
}

public enum BusinessType
{
    Retail = 0,
    Manufacturing = 1,
    Service = 2,
    Wholesale = 3,
    FoodAndBeverage = 4,
    Agriculture = 5,
    Other = 6
}

public enum RiskLevel
{
    Low = 0,
    Moderate = 1,
    High = 2,
    Critical = 3
}

public enum HealthStatus
{
    Weak = 0,
    Fair = 1,
    Healthy = 2,
    Strong = 3
}

public enum UserRole
{
    User = 0,
    Admin = 1
}
