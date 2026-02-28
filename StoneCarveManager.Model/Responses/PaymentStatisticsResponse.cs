using System.Collections.Generic;

namespace StoneCarveManager.Model.Responses
{
    public class PaymentStatisticsResponse
    {
        /// <summary>
        /// NET Revenue (Gross Revenue - Total Refunds)
        /// This is the actual money you earned and kept.
        /// </summary>
        public decimal TotalRevenue { get; set; }
        
        public int SuccessfulCount { get; set; }
        public int FailedCount { get; set; }
        public int PendingCount { get; set; }
        
        /// <summary>
        /// Total amount refunded to customers.
        /// Includes both partial and full refunds.
        /// </summary>
        public decimal RefundedAmount { get; set; }
        
        /// <summary>
        /// NET Revenue by payment method (after refunds)
        /// </summary>
        public Dictionary<string, decimal> RevenueByMethod { get; set; } = new();
    }
}
