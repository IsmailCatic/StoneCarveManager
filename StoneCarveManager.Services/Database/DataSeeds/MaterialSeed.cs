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
                    ImageUrl = "/images/materials/white-marble.jpg",
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
                    ImageUrl = "/images/materials/black-granite. jpg",
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
                    ImageUrl = "/images/materials/limestone.jpg",
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
                    ImageUrl = "/images/materials/sandstone. jpg",
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
                    ImageUrl = "/images/materials/travertine. jpg",
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
                    ImageUrl = "/images/materials/onyx.jpg",
                    PricePerUnit = 350.00m,
                    Unit = "m²",
                    QuantityInStock = 10,
                    IsAvailable = true,
                    IsActive = true,
                    CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc)
                }
            );
        }
    }
}
