using Microsoft.EntityFrameworkCore;
using StoneCarveManager.Services.Database.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.Database.DataSeeds
{
    internal static class MaterialSeed
    {
        public static void Seed(ModelBuilder builder)
        {
            builder.Entity<Material>().HasData(
                new Material
                {
                    Id = 1,
                    Name = "White Marble",
                    Description = "Premium quality white marble, perfect for detailed sculptures",
                    ImageUrl = "https://stonecarvemanagerstorage.blob.core.windows.net/material-images/f94d05e3-8fe7-49cc-a683-2d1d43fc2540.jpg",
                    PricePerUnit = 180.00m,
                    Unit = "m²",
                    QuantityInStock = 50,
                    IsAvailable = true,
                    IsActive = true,
                    CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc)
                },
                new Material
                {
                    Id = 2,
                    Name = "Black Granite",
                    Description = "Durable black granite with polished finish",
                    ImageUrl = "https://stonecarvemanagerstorage.blob.core.windows.net/material-images/c6c6aa69-848f-4dfd-983b-1ed1a76f8084.jpg",
                    PricePerUnit = 220.00m,
                    Unit = "m²",
                    QuantityInStock = 35,
                    IsAvailable = true,
                    IsActive = true,
                    CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc)
                },
                new Material
                {
                    Id = 3,
                    Name = "Limestone",
                    Description = "Natural beige limestone, ideal for outdoor projects",
                    ImageUrl = "https://stonecarvemanagerstorage.blob.core.windows.net/material-images/aaa1fa10-a93d-4616-bbcc-7b11e69852d5.jpg",
                    PricePerUnit = 120.00m,
                    Unit = "m²",
                    QuantityInStock = 80,
                    IsAvailable = true,
                    IsActive = true,
                    CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc)
                },
                new Material
                {
                    Id = 4,
                    Name = "Sandstone",
                    Description = "Warm-toned sandstone with unique texture",
                    ImageUrl = "https://stonecarvemanagerstorage.blob.core.windows.net/material-images/a3b7406c-3c2c-46ec-ac3f-563242c0b66b.jpg",
                    PricePerUnit = 95.00m,
                    Unit = "m²",
                    QuantityInStock = 60,
                    IsAvailable = true,
                    IsActive = true,
                    CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc)
                },
                new Material
                {
                    Id = 5,
                    Name = "Travertine",
                    Description = "Classic cream-colored travertine stone",
                    ImageUrl = "https://stonecarvemanagerstorage.blob.core.windows.net/material-images/af8d25c3-e8df-4026-85db-55fc29536634.jpg",
                    PricePerUnit = 150.00m,
                    Unit = "m²",
                    QuantityInStock = 40,
                    IsAvailable = true,
                    IsActive = true,
                    CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc)
                },
                new Material
                {
                    Id = 6,
                    Name = "Onyx",
                    Description = "Rare translucent onyx for luxury projects",
                    ImageUrl = "https://stonecarvemanagerstorage.blob.core.windows.net/material-images/f3e0fb4d-e655-4a6e-a95d-c5de0f0e6f4c.jpg",
                    PricePerUnit = 350.00m,
                    Unit = "m²",
                    QuantityInStock = 10,
                    IsAvailable = true,
                    IsActive = true,
                    CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc)
                },
                new Material
                {
                    Id = 8,
                    Name = "Blue limestone",
                    Description = "Blue limestone sourced from Herzegovina",
                    ImageUrl = "https://stonecarvemanagerstorage.blob.core.windows.net/material-images/10d3a1da-7fd0-4fe5-8fc4-80a09e76efd5.jpg",
                    PricePerUnit = 33.00m,
                    Unit = "pcs",
                    QuantityInStock = 100,
                    IsAvailable = true,
                    IsActive = true,
                    CreatedAt = new DateTime(2026, 2, 28, 21, 53, 34, DateTimeKind.Utc)
                }
            );
        }
    }
}
