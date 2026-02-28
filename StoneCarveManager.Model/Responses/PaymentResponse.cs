using System;

namespace StoneCarveManager.Model.Responses
{
    public class PaymentResponse
    {
        public int Id { get; set; }
        public int OrderId { get; set; }
        public string OrderNumber { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public string Currency { get; set; } = "BAM";
        public string Status { get; set; } = string.Empty; // pending, succeeded, failed, cancelled, refunded, partially_refunded
        public string Method { get; set; } = string.Empty;
        public string? TransactionId { get; set; }
        public string? StripePaymentIntentId { get; set; }
        public string? FailureReason { get; set; }
        
        /// <summary>
        /// Amount refunded to customer. Null if no refund has been issued.
        /// </summary>
        public decimal? RefundAmount { get; set; }
        
        /// <summary>
        /// Reason for refund (e.g., "damaged item", "customer request")
        /// </summary>
        public string? RefundReason { get; set; }
        
        /// <summary>
        /// When the refund was processed
        /// </summary>
        public DateTime? RefundedAt { get; set; }
        
        /// <summary>
        /// Net amount after refunds (Amount - RefundAmount)
        /// </summary>
        public decimal NetAmount => Amount - (RefundAmount ?? 0);
        
        /// <summary>
        /// Current order status (useful for understanding context of refunded payments)
        /// </summary>
        public string? OrderStatus { get; set; }
        
        public DateTime CreatedAt { get; set; }
        public DateTime? CompletedAt { get; set; }
        public string? CustomerName { get; set; }
        public string? CustomerEmail { get; set; }
    }
}
