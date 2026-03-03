using Microsoft.EntityFrameworkCore;
using StoneCarveManager.Services.Database.Entities;
using System;

namespace StoneCarveManager.Services.Database.DataSeeds
{
    internal static class PaymentSeed
    {
        public static void Seed(ModelBuilder builder)
        {
            builder.Entity<Payment>().HasData(

                // ?? Order 1: user1 — Delivered — 1840.00 ??????????????????????????
                new Payment
                {
                    Id = 1,
                    OrderId = 1,
                    Amount = 1840.00m,
                    Method = "stripe",
                    Status = "succeeded",
                    TransactionId = "txn_seed_001",
                    StripePaymentIntentId = "pi_seed_001_ORD2024001",
                    RefundAmount = null,
                    RefundReason = null,
                    RefundedAt = null,
                    FailureReason = null,
                    CreatedAt = new DateTime(2024, 2, 1, 10, 5, 0, DateTimeKind.Utc),
                    CompletedAt = new DateTime(2024, 2, 1, 10, 6, 0, DateTimeKind.Utc)
                },

                // ?? Order 2: user2 — Delivered — 750.00 ???????????????????????????
                new Payment
                {
                    Id = 2,
                    OrderId = 2,
                    Amount = 750.00m,
                    Method = "cash",
                    Status = "succeeded",
                    TransactionId = null,
                    StripePaymentIntentId = null,
                    RefundAmount = null,
                    RefundReason = null,
                    RefundedAt = null,
                    FailureReason = null,
                    CreatedAt = new DateTime(2024, 3, 22, 11, 0, 0, DateTimeKind.Utc),
                    CompletedAt = new DateTime(2024, 3, 22, 11, 0, 0, DateTimeKind.Utc)
                },

                // ?? Order 3: user3 — Delivered — 2500.00 ??????????????????????????
                new Payment
                {
                    Id = 3,
                    OrderId = 3,
                    Amount = 2500.00m,
                    Method = "stripe",
                    Status = "succeeded",
                    TransactionId = "txn_seed_003",
                    StripePaymentIntentId = "pi_seed_003_ORD2024003",
                    RefundAmount = null,
                    RefundReason = null,
                    RefundedAt = null,
                    FailureReason = null,
                    CreatedAt = new DateTime(2024, 4, 5, 9, 5, 0, DateTimeKind.Utc),
                    CompletedAt = new DateTime(2024, 4, 5, 9, 6, 0, DateTimeKind.Utc)
                },

                // ?? Order 4: user1 — Processing — 3200.00 — paid, now being worked on ??
                new Payment
                {
                    Id = 4,
                    OrderId = 4,
                    Amount = 3200.00m,
                    Method = "stripe",
                    Status = "succeeded",
                    TransactionId = "txn_seed_004",
                    StripePaymentIntentId = "pi_seed_004_ORD2024004",
                    RefundAmount = null,
                    RefundReason = null,
                    RefundedAt = null,
                    FailureReason = null,
                    CreatedAt = new DateTime(2024, 11, 15, 14, 5, 0, DateTimeKind.Utc),
                    CompletedAt = new DateTime(2024, 11, 15, 14, 6, 0, DateTimeKind.Utc)
                },

                // Order 5 (Pending) intentionally has no payment — not yet confirmed.

                // ?? Order 6: user3 — Delivered — 840.00 ???????????????????????????
                new Payment
                {
                    Id = 5,
                    OrderId = 6,
                    Amount = 840.00m,
                    Method = "stripe",
                    Status = "succeeded",
                    TransactionId = "txn_seed_006",
                    StripePaymentIntentId = "pi_seed_006_ORD2026001",
                    RefundAmount = null,
                    RefundReason = null,
                    RefundedAt = null,
                    FailureReason = null,
                    CreatedAt = new DateTime(2026, 1, 8, 9, 35, 0, DateTimeKind.Utc),
                    CompletedAt = new DateTime(2026, 1, 8, 9, 36, 0, DateTimeKind.Utc)
                },

                // ?? Order 7: user1 — Delivered — 1260.00 ??????????????????????????
                new Payment
                {
                    Id = 6,
                    OrderId = 7,
                    Amount = 1260.00m,
                    Method = "stripe",
                    Status = "succeeded",
                    TransactionId = "txn_seed_007",
                    StripePaymentIntentId = "pi_seed_007_ORD2026002",
                    RefundAmount = null,
                    RefundReason = null,
                    RefundedAt = null,
                    FailureReason = null,
                    CreatedAt = new DateTime(2026, 2, 3, 11, 5, 0, DateTimeKind.Utc),
                    CompletedAt = new DateTime(2026, 2, 3, 11, 6, 0, DateTimeKind.Utc)
                },

                // ?? Order 8: user2 — Processing — 1850.00 — paid, being worked on ?
                new Payment
                {
                    Id = 7,
                    OrderId = 8,
                    Amount = 1850.00m,
                    Method = "stripe",
                    Status = "succeeded",
                    TransactionId = "txn_seed_008",
                    StripePaymentIntentId = "pi_seed_008_ORD2026003",
                    RefundAmount = null,
                    RefundReason = null,
                    RefundedAt = null,
                    FailureReason = null,
                    CreatedAt = new DateTime(2026, 3, 1, 14, 20, 0, DateTimeKind.Utc),
                    CompletedAt = new DateTime(2026, 3, 1, 14, 21, 0, DateTimeKind.Utc)
                },

                // ?? Order 18: user2 — Processing — 299.00 — service_request ???????
                new Payment
                {
                    Id = 8,
                    OrderId = 18,
                    Amount = 299.00m,
                    Method = "stripe",
                    Status = "succeeded",
                    TransactionId = "txn_seed_018",
                    StripePaymentIntentId = "pi_seed_018_ORD20260302B04BAE",
                    RefundAmount = null,
                    RefundReason = null,
                    RefundedAt = null,
                    FailureReason = null,
                    CreatedAt = new DateTime(2026, 3, 2, 16, 8, 25, DateTimeKind.Utc),
                    CompletedAt = new DateTime(2026, 3, 2, 16, 8, 26, DateTimeKind.Utc)
                }
            );
        }
    }
}
