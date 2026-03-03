using Microsoft.EntityFrameworkCore;
using StoneCarveManager.Services.Database.Entities;
using System;

namespace StoneCarveManager.Services.Database.DataSeeds
{
    internal static class CartSeed
    {
        public static void Seed(ModelBuilder builder)
        {
            SeedCarts(builder);
            SeedCartItems(builder);
        }

        private static void SeedCarts(ModelBuilder builder)
        {
            builder.Entity<Cart>().HasData(
                new Cart
                {
                    Id = 1,
                    UserId = -301,
                    CreatedAt = new DateTime(2024, 11, 1, 14, 30, 0, DateTimeKind.Utc)
                },
                new Cart
                {
                    Id = 2,
                    UserId = -302,
                    CreatedAt = new DateTime(2025, 1, 10, 9, 15, 0, DateTimeKind.Utc)
                },
                new Cart
                {
                    Id = 3,
                    UserId = -303,
                    CreatedAt = new DateTime(2025, 2, 5, 16, 45, 0, DateTimeKind.Utc)
                }
            );
        }

        private static void SeedCartItems(ModelBuilder builder)
        {
            builder.Entity<CartItem>().HasData(
                // user1 has High Relief in cart (browsing after previous orders)
                new CartItem
                {
                    Id = 1,
                    CartId = 1,
                    ProductId = 2, // High Relief — Limestone
                    Quantity = 1,
                    CustomNotes = "Interested in a slightly larger version — will discuss dimensions",
                    AddedAt = new DateTime(2024, 11, 1, 14, 35, 0, DateTimeKind.Utc)
                },

                // user2 has Stone Balustrades in cart (planning terrace renovation)
                new CartItem
                {
                    Id = 2,
                    CartId = 2,
                    ProductId = 8, // Stone Balustrade — Limestone
                    Quantity = 4,
                    CustomNotes = "Need 4 sections for a 4-metre terrace parapet",
                    AddedAt = new DateTime(2025, 1, 10, 9, 20, 0, DateTimeKind.Utc)
                },

                // user3 has Custom Family Crest in cart
                new CartItem
                {
                    Id = 3,
                    CartId = 3,
                    ProductId = 9, // Custom Family Crest — Black Granite
                    Quantity = 1,
                    CustomNotes = "Will upload our heraldic design sketch once approved by the family",
                    AddedAt = new DateTime(2025, 2, 5, 16, 50, 0, DateTimeKind.Utc)
                }
            );
        }
    }
}
