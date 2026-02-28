using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.Database.Entities
{
    public class Payment
    {
        public int Id { get; set; }

        public decimal Amount { get; set; }

        public string Method { get; set; } = "stripe"; // stripe, cash, bank_transfer

        public string Status { get; set; } = "pending"; // pending, succeeded, failed, cancelled, refunded, partially_refunded

        public string? TransactionId { get; set; }
        
        public string? StripePaymentIntentId { get; set; }
        
        public string? FailureReason { get; set; }

        /// <summary>
        /// Amount refunded to customer. Null if no refund.
        /// For partial refunds: RefundAmount < Amount
        /// For full refunds: RefundAmount = Amount
        /// Net Revenue = Amount - RefundAmount
        /// </summary>
        public decimal? RefundAmount { get; set; }

        /// <summary>
        /// Reason for refund (e.g., "damaged item", "customer request", "wrong product")
        /// </summary>
        public string? RefundReason { get; set; }

        /// <summary>
        /// When the refund was processed
        /// </summary>
        public DateTime? RefundedAt { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? CompletedAt { get; set; }

        // Foreign Key
        public int OrderId { get; set; }
        public Order Order { get; set; } = null!;

        /// <summary>
        /// Calculates net revenue after refunds
        /// </summary>
        [NotMapped]
        public decimal NetAmount => Amount - (RefundAmount ?? 0);
    }
}
