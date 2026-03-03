using Microsoft.EntityFrameworkCore;
using StoneCarveManager.Services.Database.Entities;
using System;

namespace StoneCarveManager.Services.Database.DataSeeds
{
    internal static class FavoriteProductSeed
    {
        public static void Seed(ModelBuilder builder)
        {
            builder.Entity<FavoriteProduct>().HasData(
                // user1 favourites — interested in large architectural pieces
                new FavoriteProduct
                {
                    Id = 1,
                    UserId = -301,
                    ProductId = 3, // Tiered Fountain — Travertine
                    AddedAt = new DateTime(2024, 10, 5, 9, 0, 0, DateTimeKind.Utc)
                },
                new FavoriteProduct
                {
                    Id = 2,
                    UserId = -301,
                    ProductId = 7, // Stone Column — White Marble
                    AddedAt = new DateTime(2024, 10, 20, 11, 0, 0, DateTimeKind.Utc)
                },

                // user2 favourites — looking at decorative garden pieces
                new FavoriteProduct
                {
                    Id = 3,
                    UserId = -302,
                    ProductId = 1, // Small Crest — White Marble
                    AddedAt = new DateTime(2024, 11, 3, 14, 0, 0, DateTimeKind.Utc)
                },
                new FavoriteProduct
                {
                    Id = 4,
                    UserId = -302,
                    ProductId = 4, // Wall Fountain — White Marble
                    AddedAt = new DateTime(2024, 12, 10, 16, 0, 0, DateTimeKind.Utc)
                },

                // user3 favourites — garden and outdoor focus
                new FavoriteProduct
                {
                    Id = 5,
                    UserId = -303,
                    ProductId = 2, // Garden Bench — White Marble
                    AddedAt = new DateTime(2024, 11, 18, 10, 0, 0, DateTimeKind.Utc)
                },
                new FavoriteProduct
                {
                    Id = 6,
                    UserId = -303,
                    ProductId = 5, // Stone Balustrade — Limestone
                    AddedAt = new DateTime(2025, 1, 8, 9, 30, 0, DateTimeKind.Utc)
                }
            );
        }
    }
}
