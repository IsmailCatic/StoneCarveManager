using Microsoft.EntityFrameworkCore;
using StoneCarveManager.Services.Database.Entities;
using System;

namespace StoneCarveManager.Services.Database.DataSeeds
{
    internal static class ProductReviewSeed
    {
        public static void Seed(ModelBuilder builder)
        {
            builder.Entity<ProductReview>().HasData(
                // user1 reviews Order 1 — 5 stars (Small Crest)
                new ProductReview
                {
                    Id = 1,
                    UserId = -301,
                    ProductId = 1,
                    OrderId = 1,
                    Rating = 5,
                    Comment = "Absolutely stunning piece. The level of detail in the carving is remarkable — you can see every chisel mark was deliberate. Arrived well-packed with no damage. Will definitely order again.",
                    IsApproved = true,
                    CreatedAt = new DateTime(2024, 2, 20, 10, 0, 0, DateTimeKind.Utc)
                },

                // user2 reviews Order 2 — 5 stars (Garden Bench)
                new ProductReview
                {
                    Id = 3,
                    UserId = -302,
                    ProductId = 2,
                    OrderId = 2,
                    Rating = 5,
                    Comment = "The bench is everything I hoped for. The black granite is imposing and elegant, and the carved details add a classical touch that perfectly complements our courtyard. Solid, heavy, and built to last generations.",
                    IsApproved = true,
                    CreatedAt = new DateTime(2024, 3, 28, 9, 0, 0, DateTimeKind.Utc)
                },

                // user3 reviews Order 3 — 5 stars (Tiered Fountain)
                new ProductReview
                {
                    Id = 4,
                    UserId = -303,
                    ProductId = 3,
                    OrderId = 3,
                    Rating = 5,
                    Comment = "This fountain is a true work of art. The travertine has a natural, rustic quality that photographs beautifully. The team delivered it personally, helped position it, and even walked us through the pump setup. Exceptional service from start to finish.",
                    IsApproved = true,
                    CreatedAt = new DateTime(2024, 5, 22, 14, 0, 0, DateTimeKind.Utc)
                }
            );
        }
    }
}
