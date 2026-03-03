using System;
using Microsoft.EntityFrameworkCore;
using StoneCarveManager.Services.Database.Entities;

namespace StoneCarveManager.Services.Database.DataSeeds
{
    internal static class OrderSeed
    {
        public static void Seed(ModelBuilder builder)
        {
            SeedOrders(builder);
            SeedOrderItems(builder);
            SeedOrderStatusHistory(builder);
            SeedOrderProgressImages(builder);
        }

        private static void SeedOrders(ModelBuilder builder)
        {
            builder.Entity<Order>().HasData(
                // ── Order 1: user1 — Delivered ─────────────────────────────────────
                new Order
                {
                    Id = 1,
                    OrderNumber = "ORD-2024-001",
                    OrderDate = new DateTime(2024, 2, 1, 10, 0, 0, DateTimeKind.Utc),
                    Status = OrderStatus.Delivered,
                    TotalAmount = 1840.00m,
                    OrderType = "standard",
                    UserId = -301,
                    AssignedEmployeeId = -201,
                    CustomerNotes = "Please ensure the wall fountains have a smooth, polished finish.",
                    AdminNotes = "Delivered on time. Customer very satisfied.",
                    EstimatedCompletionDate = new DateTime(2024, 2, 20, 0, 0, 0, DateTimeKind.Utc),
                    CompletedAt = new DateTime(2024, 2, 18, 0, 0, 0, DateTimeKind.Utc),
                    DeliveryAddress = "Splitska 5",
                    DeliveryCity = "Sarajevo",
                    DeliveryZipCode = "71000",
                    DeliveryCountry = "Bosnia and Herzegovina",
                    DeliveryDate = new DateTime(2024, 2, 18, 0, 0, 0, DateTimeKind.Utc)
                },

                // ── Order 2: user2 — Delivered ─────────────────────────────────────
                new Order
                {
                    Id = 2,
                    OrderNumber = "ORD-2024-002",
                    OrderDate = new DateTime(2024, 3, 10, 11, 30, 0, DateTimeKind.Utc),
                    Status = OrderStatus.Delivered,
                    TotalAmount = 750.00m,
                    OrderType = "standard",
                    UserId = -302,
                    AssignedEmployeeId = -202,
                    CustomerNotes = "Garden bench for a shaded courtyard. Standard finish is fine.",
                    AdminNotes = "Collected in person from workshop.",
                    EstimatedCompletionDate = new DateTime(2024, 3, 25, 0, 0, 0, DateTimeKind.Utc),
                    CompletedAt = new DateTime(2024, 3, 22, 0, 0, 0, DateTimeKind.Utc),
                    DeliveryAddress = "Kneza Domagoja 12",
                    DeliveryCity = "Mostar",
                    DeliveryZipCode = "88000",
                    DeliveryCountry = "Bosnia and Herzegovina",
                    DeliveryDate = new DateTime(2024, 3, 22, 0, 0, 0, DateTimeKind.Utc)
                },

                // ── Order 3: user3 — Delivered (large fountain) ────────────────────
                new Order
                {
                    Id = 3,
                    OrderNumber = "ORD-2024-003",
                    OrderDate = new DateTime(2024, 4, 5, 9, 0, 0, DateTimeKind.Utc),
                    Status = OrderStatus.Delivered,
                    TotalAmount = 2500.00m,
                    OrderType = "standard",
                    UserId = -303,
                    AssignedEmployeeId = -201,
                    CustomerNotes = "The fountain will be the centrepiece of a new courtyard. Please include the pump and fitting instructions.",
                    AdminNotes = "Delivered by our team with crane assist. Installation guidance provided on-site.",
                    EstimatedCompletionDate = new DateTime(2024, 5, 20, 0, 0, 0, DateTimeKind.Utc),
                    CompletedAt = new DateTime(2024, 5, 16, 0, 0, 0, DateTimeKind.Utc),
                    DeliveryAddress = "Bulevar Mese Selimovica 44",
                    DeliveryCity = "Tuzla",
                    DeliveryZipCode = "75000",
                    DeliveryCountry = "Bosnia and Herzegovina",
                    DeliveryDate = new DateTime(2024, 5, 16, 0, 0, 0, DateTimeKind.Utc)
                },

                // ── Order 4: user1 — Processing (stone column) ─────────────────────
                new Order
                {
                    Id = 4,
                    OrderNumber = "ORD-2024-004",
                    OrderDate = new DateTime(2024, 11, 15, 14, 0, 0, DateTimeKind.Utc),
                    Status = OrderStatus.Processing,
                    TotalAmount = 3200.00m,
                    OrderType = "standard",
                    UserId = -301,
                    AssignedEmployeeId = -202,
                    CustomerNotes = "Classical Corinthian column for a home library. Pedestal base would be appreciated if feasible.",
                    AdminNotes = "Capital carving is underway. Will update client by end of week.",
                    EstimatedCompletionDate = new DateTime(2025, 1, 15, 0, 0, 0, DateTimeKind.Utc),
                    DeliveryAddress = "Splitska 5",
                    DeliveryCity = "Sarajevo",
                    DeliveryZipCode = "71000",
                    DeliveryCountry = "Bosnia and Herzegovina"
                },

                // ── Order 5: user2 — Pending (wall fountain) ───────────────────────
                new Order
                {
                    Id = 5,
                    OrderNumber = "ORD-2025-001",
                    OrderDate = new DateTime(2025, 1, 20, 16, 45, 0, DateTimeKind.Utc),
                    Status = OrderStatus.Pending,
                    TotalAmount = 980.00m,
                    OrderType = "standard",
                    UserId = -302,
                    CustomerNotes = "Wall fountain for an outdoor terrace. Would prefer the lion head to face left instead of right if possible.",
                    EstimatedCompletionDate = new DateTime(2025, 2, 10, 0, 0, 0, DateTimeKind.Utc),
                    DeliveryAddress = "Kneza Domagoja 12",
                    DeliveryCity = "Mostar",
                    DeliveryZipCode = "88000",
                    DeliveryCountry = "Bosnia and Herzegovina"
                },

                // ── Order 6: user3 — Delivered (Geometric Wall Panel + Floral Panel) ─
                new Order
                {
                    Id = 6,
                    OrderNumber = "ORD-2026-001",
                    OrderDate = new DateTime(2026, 1, 8, 9, 30, 0, DateTimeKind.Utc),
                    Status = OrderStatus.Delivered,
                    TotalAmount = 840.00m,
                    OrderType = "standard",
                    UserId = -303,
                    AssignedEmployeeId = -203,
                    CustomerNotes = "Both panels are for a new living room feature wall. Please ensure edges are smooth.",
                    AdminNotes = "Panels cut and polished to spec. Delivered without issue.",
                    EstimatedCompletionDate = new DateTime(2026, 1, 22, 0, 0, 0, DateTimeKind.Utc),
                    CompletedAt = new DateTime(2026, 1, 20, 0, 0, 0, DateTimeKind.Utc),
                    DeliveryAddress = "Bulevar Mese Selimovica 44",
                    DeliveryCity = "Tuzla",
                    DeliveryZipCode = "75000",
                    DeliveryCountry = "Bosnia and Herzegovina",
                    DeliveryDate = new DateTime(2026, 1, 20, 0, 0, 0, DateTimeKind.Utc)
                },

                // ── Order 7: user1 — Delivered (Stone Balustrade × 3) ─────────────
                new Order
                {
                    Id = 7,
                    OrderNumber = "ORD-2026-002",
                    OrderDate = new DateTime(2026, 2, 3, 11, 0, 0, DateTimeKind.Utc),
                    Status = OrderStatus.Delivered,
                    TotalAmount = 1260.00m,
                    OrderType = "standard",
                    UserId = -301,
                    AssignedEmployeeId = -201,
                    CustomerNotes = "Three balustrade sections for a garden terrace. Matching finish to existing stonework if possible.",
                    AdminNotes = "All three sections finished to a consistent honed finish. Delivered and installed.",
                    EstimatedCompletionDate = new DateTime(2026, 2, 20, 0, 0, 0, DateTimeKind.Utc),
                    CompletedAt = new DateTime(2026, 2, 18, 0, 0, 0, DateTimeKind.Utc),
                    DeliveryAddress = "Splitska 5",
                    DeliveryCity = "Sarajevo",
                    DeliveryZipCode = "71000",
                    DeliveryCountry = "Bosnia and Herzegovina",
                    DeliveryDate = new DateTime(2026, 2, 18, 0, 0, 0, DateTimeKind.Utc)
                },

                // ── Order 8: user2 — Processing (High Relief Panel) ───────────────
                new Order
                {
                    Id = 8,
                    OrderNumber = "ORD-2026-003",
                    OrderDate = new DateTime(2026, 3, 1, 14, 15, 0, DateTimeKind.Utc),
                    Status = OrderStatus.Processing,
                    TotalAmount = 1850.00m,
                    OrderType = "standard",
                    UserId = -302,
                    AssignedEmployeeId = -202,
                    CustomerNotes = "High relief panel for an entrance hall. Prefer a matte finish.",
                    AdminNotes = "Relief carving in progress. Background work completed, figures being detailed.",
                    EstimatedCompletionDate = new DateTime(2026, 4, 1, 0, 0, 0, DateTimeKind.Utc),
                    DeliveryAddress = "Kneza Domagoja 12",
                    DeliveryCity = "Mostar",
                    DeliveryZipCode = "88000",
                    DeliveryCountry = "Bosnia and Herzegovina"
                }
            );
        }

        private static void SeedOrderItems(ModelBuilder builder)
        {
            builder.Entity<OrderItem>().HasData(
                // Order 1 items: Small Crest + 2× Wall Fountain
                new OrderItem
                {
                    Id = 1,
                    OrderId = 1,
                    ProductId = 1, // Small Crest — White Marble
                    Quantity = 1,
                    UnitPrice = 1200.00m,
                    Discount = 0m
                },
                new OrderItem
                {
                    Id = 2,
                    OrderId = 1,
                    ProductId = 4, // Wall Fountain — White Marble
                    Quantity = 2,
                    UnitPrice = 320.00m,
                    Discount = 0m
                },

                // Order 2 items: Garden Bench
                new OrderItem
                {
                    Id = 3,
                    OrderId = 2,
                    ProductId = 2, // Garden Bench — White Marble
                    Quantity = 1,
                    UnitPrice = 750.00m,
                    Discount = 0m
                },

                // Order 3 items: Tiered Fountain
                new OrderItem
                {
                    Id = 4,
                    OrderId = 3,
                    ProductId = 3, // Tiered Fountain — Travertine
                    Quantity = 1,
                    UnitPrice = 2500.00m,
                    Discount = 0m
                },

                // Order 4 items: Stone Column
                new OrderItem
                {
                    Id = 5,
                    OrderId = 4,
                    ProductId = 7, // Stone Column — White Marble
                    Quantity = 1,
                    UnitPrice = 3200.00m,
                    Discount = 0m
                },

                // Order 5 items: Wall Fountain
                new OrderItem
                {
                    Id = 6,
                    OrderId = 5,
                    ProductId = 4, // Wall Fountain — White Marble
                    Quantity = 1,
                    UnitPrice = 980.00m,
                    Discount = 0m
                },

                // Order 6 items: Geometric Wall Panel + Floral Panel
                new OrderItem
                {
                    Id = 7,
                    OrderId = 6,
                    ProductId = 8, // Geometric Wall Panel — Sandstone
                    Quantity = 1,
                    UnitPrice = 400.00m,
                    Discount = 0m
                },
                new OrderItem
                {
                    Id = 8,
                    OrderId = 6,
                    ProductId = 9, // Floral Wall Panel — Sandstone
                    Quantity = 1,
                    UnitPrice = 440.00m,
                    Discount = 0m
                },

                // Order 7 items: Stone Balustrade × 3
                new OrderItem
                {
                    Id = 9,
                    OrderId = 7,
                    ProductId = 10, // Stone Balustrade — White Marble
                    Quantity = 3,
                    UnitPrice = 420.00m,
                    Discount = 0m
                },

                // Order 8 items: High Relief Panel
                new OrderItem
                {
                    Id = 10,
                    OrderId = 8,
                    ProductId = 11, // High Relief Panel — White Marble
                    Quantity = 1,
                    UnitPrice = 1850.00m,
                    Discount = 0m
                }
            );
        }

        private static void SeedOrderStatusHistory(ModelBuilder builder)
        {
            builder.Entity<OrderStatusHistory>().HasData(
                // ── Order 1 history (Pending → Processing → Shipped → Delivered) ───
                new OrderStatusHistory
                {
                    Id = 1,
                    OrderId = 1,
                    OldStatus = OrderStatus.Pending,
                    NewStatus = OrderStatus.Processing,
                    Comment = "Order confirmed and carving has started.",
                    ChangedByUserId = -201,
                    ChangedAt = new DateTime(2024, 2, 3, 8, 0, 0, DateTimeKind.Utc)
                },
                new OrderStatusHistory
                {
                    Id = 2,
                    OrderId = 1,
                    OldStatus = OrderStatus.Processing,
                    NewStatus = OrderStatus.Shipped,
                    Comment = "Pieces are finished and loaded for delivery.",
                    ChangedByUserId = -201,
                    ChangedAt = new DateTime(2024, 2, 16, 7, 0, 0, DateTimeKind.Utc)
                },
                new OrderStatusHistory
                {
                    Id = 3,
                    OrderId = 1,
                    OldStatus = OrderStatus.Shipped,
                    NewStatus = OrderStatus.Delivered,
                    Comment = "Delivered to customer. Signed receipt obtained.",
                    ChangedByUserId = -201,
                    ChangedAt = new DateTime(2024, 2, 18, 14, 0, 0, DateTimeKind.Utc)
                },

                // ── Order 2 history (Pending → Processing → Delivered) ─────────────
                new OrderStatusHistory
                {
                    Id = 4,
                    OrderId = 2,
                    OldStatus = OrderStatus.Pending,
                    NewStatus = OrderStatus.Processing,
                    Comment = "Order accepted. Bench fabrication underway.",
                    ChangedByUserId = -202,
                    ChangedAt = new DateTime(2024, 3, 12, 9, 0, 0, DateTimeKind.Utc)
                },
                new OrderStatusHistory
                {
                    Id = 5,
                    OrderId = 2,
                    OldStatus = OrderStatus.Processing,
                    NewStatus = OrderStatus.Delivered,
                    Comment = "Customer collected from workshop in person.",
                    ChangedByUserId = -202,
                    ChangedAt = new DateTime(2024, 3, 22, 11, 0, 0, DateTimeKind.Utc)
                },

                // ── Order 3 history (Pending → Processing → Shipped → Delivered) ───
                new OrderStatusHistory
                {
                    Id = 6,
                    OrderId = 3,
                    OldStatus = OrderStatus.Pending,
                    NewStatus = OrderStatus.Processing,
                    Comment = "Fountain blocks received from quarry. Carving has begun.",
                    ChangedByUserId = -201,
                    ChangedAt = new DateTime(2024, 4, 8, 8, 0, 0, DateTimeKind.Utc)
                },
                new OrderStatusHistory
                {
                    Id = 7,
                    OrderId = 3,
                    OldStatus = OrderStatus.Processing,
                    NewStatus = OrderStatus.Shipped,
                    Comment = "All three tiers complete and loaded on delivery van.",
                    ChangedByUserId = -201,
                    ChangedAt = new DateTime(2024, 5, 14, 7, 30, 0, DateTimeKind.Utc)
                },
                new OrderStatusHistory
                {
                    Id = 8,
                    OrderId = 3,
                    OldStatus = OrderStatus.Shipped,
                    NewStatus = OrderStatus.Delivered,
                    Comment = "Fountain delivered and placed in courtyard. Installation guidance given.",
                    ChangedByUserId = -201,
                    ChangedAt = new DateTime(2024, 5, 16, 15, 0, 0, DateTimeKind.Utc)
                },

                // ── Order 4 history (Pending → Processing) ──────────────────────────
                new OrderStatusHistory
                {
                    Id = 9,
                    OrderId = 4,
                    OldStatus = OrderStatus.Pending,
                    NewStatus = OrderStatus.Processing,
                    Comment = "Marble block sourced. Column shaft roughing in progress.",
                    ChangedByUserId = -202,
                    ChangedAt = new DateTime(2024, 11, 18, 8, 0, 0, DateTimeKind.Utc)
                },

                // ── Order 6 history (Pending → Processing → Shipped → Delivered) ───
                new OrderStatusHistory
                {
                    Id = 10,
                    OrderId = 6,
                    OldStatus = OrderStatus.Pending,
                    NewStatus = OrderStatus.Processing,
                    Comment = "Panel designs approved. Cutting and polishing in progress.",
                    ChangedByUserId = -203,
                    ChangedAt = new DateTime(2026, 1, 10, 9, 0, 0, DateTimeKind.Utc)
                },
                new OrderStatusHistory
                {
                    Id = 11,
                    OrderId = 6,
                    OldStatus = OrderStatus.Processing,
                    NewStatus = OrderStatus.Shipped,
                    Comment = "Panels completed and dispatched.",
                    ChangedByUserId = -203,
                    ChangedAt = new DateTime(2026, 1, 15, 15, 0, 0, DateTimeKind.Utc)
                },
                new OrderStatusHistory
                {
                    Id = 12,
                    OrderId = 6,
                    OldStatus = OrderStatus.Shipped,
                    NewStatus = OrderStatus.Delivered,
                    Comment = "Delivered and installed on schedule.",
                    ChangedByUserId = -203,
                    ChangedAt = new DateTime(2026, 1, 20, 16, 0, 0, DateTimeKind.Utc)
                },

                // ── Order 7 history (Pending → Processing → Delivered) ─────────────
                new OrderStatusHistory
                {
                    Id = 13,
                    OrderId = 7,
                    OldStatus = OrderStatus.Pending,
                    NewStatus = OrderStatus.Processing,
                    Comment = "Balustrade design finalized. Fabrication has begun.",
                    ChangedByUserId = -201,
                    ChangedAt = new DateTime(2026, 2, 5, 10, 0, 0, DateTimeKind.Utc)
                },
                new OrderStatusHistory
                {
                    Id = 14,
                    OrderId = 7,
                    OldStatus = OrderStatus.Processing,
                    NewStatus = OrderStatus.Delivered,
                    Comment = "Three balustrade sections delivered and installed.",
                    ChangedByUserId = -201,
                    ChangedAt = new DateTime(2026, 2, 18, 14, 0, 0, DateTimeKind.Utc)
                },

                // ── Order 8 history (Pending → Processing) ──────────────────────────
                new OrderStatusHistory
                {
                    Id = 15,
                    OrderId = 8,
                    OldStatus = OrderStatus.Pending,
                    NewStatus = OrderStatus.Processing,
                    Comment = "High relief panel design approved. Carving in progress.",
                    ChangedByUserId = -202,
                    ChangedAt = new DateTime(2026, 3, 5, 9, 0, 0, DateTimeKind.Utc)
                }
            );
        }

        private static void SeedOrderProgressImages(ModelBuilder builder)
        {
            builder.Entity<OrderProgressImage>().HasData(
                // Order 3 — Tiered Fountain progress photos (while in production)
                new OrderProgressImage
                {
                    Id = 1,
                    OrderId = 3,
                    ImageUrl = "https://stonecarvemanagerstorage.blob.core.windows.net/order-progress/18eb1959-f371-4f85-9926-33029d09b8b3.jpg",
                    Description = "Lower basin rough-cut complete. Acanthus leaf border work has started.",
                    UploadedByUserId = -201,
                    UploadedAt = new DateTime(2024, 4, 20, 12, 0, 0, DateTimeKind.Utc)
                },
                new OrderProgressImage
                {
                    Id = 2,
                    OrderId = 3,
                    ImageUrl = "https://stonecarvemanagerstorage.blob.core.windows.net/order-progress/788f94ff-e47d-4a8b-99c8-26abcc9fbb29.jpg",
                    Description = "All three tiers carved and polished. Ready for final assembly check.",
                    UploadedByUserId = -201,
                    UploadedAt = new DateTime(2024, 5, 10, 10, 0, 0, DateTimeKind.Utc)
                },

                // Order 4 — Stone Column in progress
                new OrderProgressImage
                {
                    Id = 3,
                    OrderId = 4,
                    ImageUrl = "https://stonecarvemanagerstorage.blob.core.windows.net/order-progress/67443ec5-1508-42e7-b88e-3f203f16a8fb.jpg",
                    Description = "Column shaft turned and fluted. Capital carving begins next week.",
                    UploadedByUserId = -202,
                    UploadedAt = new DateTime(2024, 12, 5, 11, 0, 0, DateTimeKind.Utc)
                },

                // Order 8 — High Relief Panel progress photos
                new OrderProgressImage
                {
                    Id = 4,
                    OrderId = 8,
                    ImageUrl = "https://stonecarvemanagerstorage.blob.core.windows.net/order-progress/4a9567a3-80a1-4f14-94a2-37c6c9017f15.jpg",
                    Description = "Panel outline and major forms blocked in. Detailing in progress.",
                    UploadedByUserId = -202,
                    UploadedAt = new DateTime(2026, 3, 15, 10, 30, 0, DateTimeKind.Utc)
                }
            );
        }
    }
}
