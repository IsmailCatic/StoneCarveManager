using Microsoft.EntityFrameworkCore;
using StoneCarveManager.Services.Database.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.Database.DataSeeds
{
    internal static class ProductSeed
    {
        public static void Seed(ModelBuilder builder)
        {
            builder.Entity<Product>().HasData(
                // Statues
                new Product
                {
                    Id = 1,
                    Name = "Small Crest",
                    Description = "Beautiful hand-carved small crest in white marble, perfect for garden decoration",
                    Price = 1200.00m,
                    StockQuantity = 3,
                    Dimensions = "30cm x 40cm x 2cm",
                    Weight = 85.5m,
                    EstimatedDays = 14,
                    IsInPortfolio = true,
                    ProductState = "available",
                    CategoryId = 1,
                    MaterialId = 1,
                    CreatedAt = new DateTime(2024, 1, 15, 0, 0, 0, DateTimeKind.Utc)
                },
                new Product
                {
                    Id = 2,
                    Name = "High relief",
                    Description = "Majestic high relief carved from limestone",
                    Price = 1850.00m,
                    StockQuantity = 2,
                    Dimensions = "90cm x 70cm x 50cm",
                    Weight = 120.0m,
                    EstimatedDays = 21,
                    IsInPortfolio = true,
                    ProductState = "available",
                    CategoryId = 1,
                    MaterialId = 3,
                    CreatedAt = new DateTime(2024, 1, 20, 0, 0, 0, DateTimeKind.Utc)
                },

                // Garden Decorations
                new Product
                {
                    Id = 3,
                    Name = "Garden Bench",
                    Description = "Elegant curved stone bench for gardens and parks",
                    Price = 750.00m,
                    StockQuantity = 5,
                    Dimensions = "180cm x 60cm x 45cm",
                    Weight = 200.0m,
                    EstimatedDays = 10,
                    IsInPortfolio = true,
                    ProductState = "available",
                    CategoryId = 2,
                    MaterialId = 2,
                    CreatedAt = new DateTime(2024, 2, 1, 0, 0, 0, DateTimeKind.Utc)
                },
                new Product
                {
                    Id = 4,
                    Name = "Bird Bath",
                    Description = "Classic stone bird bath with detailed carvings",
                    Price = 320.00m,
                    StockQuantity = 8,
                    Dimensions = "80cm x 80cm x 70cm",
                    Weight = 45.0m,
                    EstimatedDays = 7,
                    IsInPortfolio = true,
                    ProductState = "available",
                    CategoryId = 2,
                    MaterialId = 4,
                    CreatedAt = new DateTime(2024, 2, 5, 0, 0, 0, DateTimeKind.Utc)
                },

                // Fountains
                new Product
                {
                    Id = 5,
                    Name = "Tiered Fountain",
                    Description = "Three-tier decorative water fountain in travertine",
                    Price = 2500.00m,
                    StockQuantity = 1,
                    Dimensions = "150cm diameter x 200cm height",
                    Weight = 350.0m,
                    EstimatedDays = 30,
                    IsInPortfolio = true,
                    ProductState = "available",
                    CategoryId = 3,
                    MaterialId = 5,
                    CreatedAt = new DateTime(2024, 2, 10, 0, 0, 0, DateTimeKind.Utc)
                },
                new Product
                {
                    Id = 6,
                    Name = "Wall Fountain",
                    Description = "Elegant wall-mounted fountain with lion head design",
                    Price = 980.00m,
                    StockQuantity = 4,
                    Dimensions = "60cm x 40cm x 30cm",
                    Weight = 55.0m,
                    EstimatedDays = 12,
                    IsInPortfolio = true,
                    ProductState = "available",
                    CategoryId = 3,
                    MaterialId = 1,
                    CreatedAt = new DateTime(2024, 2, 15, 0, 0, 0, DateTimeKind.Utc)
                },

                // Architectural Elements
                new Product
                {
                    Id = 7,
                    Name = "Stone Column",
                    Description = "Classical Corinthian column in white marble",
                    Price = 3200.00m,
                    StockQuantity = 6,
                    Dimensions = "250cm height x 40cm diameter",
                    Weight = 280.0m,
                    EstimatedDays = 25,
                    IsInPortfolio = true,
                    ProductState = "available",
                    CategoryId = 4,
                    MaterialId = 1,
                    CreatedAt = new DateTime(2024, 2, 20, 0, 0, 0, DateTimeKind.Utc)
                },
                new Product
                {
                    Id = 8,
                    Name = "Stone Balustrade",
                    Description = "Decorative balustrade section (per meter)",
                    Price = 420.00m,
                    StockQuantity = 20,
                    Dimensions = "100cm x 15cm x 80cm",
                    Weight = 65.0m,
                    EstimatedDays = 8,
                    IsInPortfolio = true,
                    ProductState = "available",
                    CategoryId = 4,
                    MaterialId = 3,
                    CreatedAt = new DateTime(2024, 2, 25, 0, 0, 0, DateTimeKind.Utc)
                },

                // Custom Carvings
                new Product
                {
                    Id = 9,
                    Name = "Custom Family Crest",
                    Description = "Personalized family crest carved in stone",
                    Price = 1500.00m,
                    StockQuantity = 0,
                    Dimensions = "Custom size",
                    Weight = null,
                    EstimatedDays = 21,
                    IsInPortfolio = true,
                    ProductState = "custom_order",
                    CategoryId = 5,
                    MaterialId = 2,
                    CreatedAt = new DateTime(2024, 3, 1, 0, 0, 0, DateTimeKind.Utc)
                },
                new Product
                {
                    Id = 10,
                    Name = "Custom Text Engraving",
                    Description = "Custom text or quote engraved on stone plaque",
                    Price = 250.00m,
                    StockQuantity = 0,
                    Dimensions = "50cm x 30cm x 5cm",
                    Weight = 12.0m,
                    EstimatedDays = 5,
                    IsInPortfolio = true,
                    ProductState = "custom_order",
                    CategoryId = 5,
                    MaterialId = 4,
                    CreatedAt = new DateTime(2024, 3, 5, 0, 0, 0, DateTimeKind.Utc)
                }
            );
        }
    }
}
