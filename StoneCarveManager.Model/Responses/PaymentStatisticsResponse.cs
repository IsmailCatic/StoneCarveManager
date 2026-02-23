using System.Collections.Generic;

namespace StoneCarveManager.Model.Responses
{
    public class PaymentStatisticsResponse
    {
        public decimal TotalRevenue { get; set; }
        public int SuccessfulCount { get; set; }
        public int FailedCount { get; set; }
        public int PendingCount { get; set; }
        public decimal RefundedAmount { get; set; }
        public Dictionary<string, decimal> RevenueByMethod { get; set; } = new();
    }
}
