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

        public string Status { get; set; } = "pending"; // pending, succeeded, failed, cancelled, refunded

        public string? TransactionId { get; set; }
        
        public string? StripePaymentIntentId { get; set; }
        
        public string? FailureReason { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? CompletedAt { get; set; }

        // Foreign Key
        public int OrderId { get; set; }
        public Order Order { get; set; } = null!;
    }
}
