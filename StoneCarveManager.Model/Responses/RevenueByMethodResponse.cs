namespace StoneCarveManager.Model.Responses
{
    public class RevenueByMethodResponse
    {
        public string PaymentMethod { get; set; } = string.Empty;
        public decimal TotalRevenue { get; set; }
        public int OrderCount { get; set; }
        public decimal Percentage { get; set; }
    }
}
