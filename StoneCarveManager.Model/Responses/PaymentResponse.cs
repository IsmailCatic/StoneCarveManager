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
        public string Status { get; set; } = string.Empty; // pending, succeeded, failed, cancelled
        public string Method { get; set; } = string.Empty;
        public string? TransactionId { get; set; }
        public string? StripePaymentIntentId { get; set; }
        public string? FailureReason { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? CompletedAt { get; set; }
    }
}
