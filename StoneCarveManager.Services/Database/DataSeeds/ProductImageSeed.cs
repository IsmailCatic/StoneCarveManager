using Microsoft.EntityFrameworkCore;
using StoneCarveManager.Services.Database.Entities;
using System;

namespace StoneCarveManager.Services.Database.DataSeeds
{
    internal static class ProductImageSeed
    {
        public static void Seed(ModelBuilder builder)
        {
            builder.Entity<ProductImage>().HasData(

                // Product 1 — Small Crest (images 21 & 22 from old DB)
                new ProductImage
                {
                    Id = 1,
                    ProductId = 1,
                    ImageUrl = "https://stonecarvemanagerstorage.blob.core.windows.net/product-images/af11f526-260b-456c-8afa-1d9fbf5f8e54.JPG",
                    AltText = null,
                    IsPrimary = true,
                    DisplayOrder = 0,
                    CreatedAt = new DateTime(2024, 1, 15, 0, 0, 0, DateTimeKind.Utc)
                },
                new ProductImage
                {
                    Id = 2,
                    ProductId = 1,
                    ImageUrl = "https://stonecarvemanagerstorage.blob.core.windows.net/product-images/ebc2f104-f7e7-4a08-92e5-8aada25e0e08.JPG",
                    AltText = null,
                    IsPrimary = false,
                    DisplayOrder = 1,
                    CreatedAt = new DateTime(2024, 1, 15, 0, 0, 0, DateTimeKind.Utc)
                },

                // Product 2 — Garden Bench (image 14 from old DB — old product 10 Installation reused, best available)
                new ProductImage
                {
                    Id = 3,
                    ProductId = 2,
                    ImageUrl = "https://stonecarvemanagerstorage.blob.core.windows.net/product-images/660a5aaa-2f46-44fa-bd0b-b97f770a9353.webp",
                    AltText = null,
                    IsPrimary = true,
                    DisplayOrder = 0,
                    CreatedAt = new DateTime(2024, 2, 1, 0, 0, 0, DateTimeKind.Utc)
                },

                // Product 3 — Tiered Fountain (image 13 from old DB — old product 3 Restoration reused, best available)
                new ProductImage
                {
                    Id = 4,
                    ProductId = 3,
                    ImageUrl = "https://stonecarvemanagerstorage.blob.core.windows.net/product-images/87629a89-0417-4661-bc00-c4985d0e200e.jpg",
                    AltText = null,
                    IsPrimary = true,
                    DisplayOrder = 0,
                    CreatedAt = new DateTime(2024, 2, 10, 0, 0, 0, DateTimeKind.Utc)
                },

                // Product 4 — Wall Fountain (using image 11 from old DB — old product 5)
                new ProductImage
                {
                    Id = 5,
                    ProductId = 4,
                    ImageUrl = "https://stonecarvemanagerstorage.blob.core.windows.net/product-images/f73a90f2-ab76-495c-aa6b-3d68a3555bab.jpg",
                    AltText = null,
                    IsPrimary = true,
                    DisplayOrder = 0,
                    CreatedAt = new DateTime(2024, 2, 15, 0, 0, 0, DateTimeKind.Utc)
                },

                // Product 5 — Stone Balustrade (image 4 from old DB — old product 8)
                new ProductImage
                {
                    Id = 6,
                    ProductId = 5,
                    ImageUrl = "https://stonecarvemanagerstorage.blob.core.windows.net/product-images/19267379-7a1e-47fb-a7ce-29931f897ad2.png",
                    AltText = null,
                    IsPrimary = true,
                    DisplayOrder = 0,
                    CreatedAt = new DateTime(2024, 2, 25, 0, 0, 0, DateTimeKind.Utc)
                },

                // Product 6 — High Relief Panel (image 3 from old DB — old product 2)
                new ProductImage
                {
                    Id = 7,
                    ProductId = 6,
                    ImageUrl = "https://stonecarvemanagerstorage.blob.core.windows.net/product-images/2b641699-ad41-4c22-8ed3-bd7c4008146c.webp",
                    AltText = null,
                    IsPrimary = true,
                    DisplayOrder = 0,
                    CreatedAt = new DateTime(2024, 1, 20, 0, 0, 0, DateTimeKind.Utc)
                },

                // Product 7 — Stone Column (image 12 from old DB — old product 7)
                new ProductImage
                {
                    Id = 8,
                    ProductId = 7,
                    ImageUrl = "https://stonecarvemanagerstorage.blob.core.windows.net/product-images/3586d760-5536-4a8d-b94c-86e76e5eaa1d.jpg",
                    AltText = null,
                    IsPrimary = true,
                    DisplayOrder = 0,
                    CreatedAt = new DateTime(2024, 2, 20, 0, 0, 0, DateTimeKind.Utc)
                },

                // Product 8 — Geometric Wall Panel (image 19 from old DB — old product 15)
                new ProductImage
                {
                    Id = 9,
                    ProductId = 8,
                    ImageUrl = "https://stonecarvemanagerstorage.blob.core.windows.net/product-images/12c27cff-40da-4702-938f-e97100cc259f.JPG",
                    AltText = null,
                    IsPrimary = true,
                    DisplayOrder = 0,
                    CreatedAt = new DateTime(2024, 3, 1, 0, 0, 0, DateTimeKind.Utc)
                },

                // Product 9 — Floral Stone Relief Panel (image 18 from old DB — old product 16)
                new ProductImage
                {
                    Id = 10,
                    ProductId = 9,
                    ImageUrl = "https://stonecarvemanagerstorage.blob.core.windows.net/product-images/4f0a0d8b-5ae3-4981-9b3d-0a6e06300925.jpg",
                    AltText = null,
                    IsPrimary = true,
                    DisplayOrder = 0,
                    CreatedAt = new DateTime(2024, 3, 5, 0, 0, 0, DateTimeKind.Utc)
                },

                // Product 10 — Restoration (old Id=3 had image 13)
                new ProductImage
                {
                    Id = 11,
                    ProductId = 10,
                    ImageUrl = "https://stonecarvemanagerstorage.blob.core.windows.net/product-images/683057e3-d7e4-4bfb-b6cc-f651006e13ec.jpg",
                    AltText = null,
                    IsPrimary = true,
                    DisplayOrder = 0,
                    CreatedAt = new DateTime(2024, 4, 1, 0, 0, 0, DateTimeKind.Utc)
                },

                // Product 11 — Custom Design & Fabrication (old Id=5 had image 11)
                new ProductImage
                {
                    Id = 12,
                    ProductId = 11,
                    ImageUrl = "https://stonecarvemanagerstorage.blob.core.windows.net/product-images/7f3eed6a-d041-483c-9d7c-075684610fa3.jpg",
                    AltText = null,
                    IsPrimary = true,
                    DisplayOrder = 0,
                    CreatedAt = new DateTime(2024, 4, 5, 0, 0, 0, DateTimeKind.Utc)
                },

                // Product 12 — Installation (old Id=10 had image 14)
                new ProductImage
                {
                    Id = 13,
                    ProductId = 12,
                    ImageUrl = "https://stonecarvemanagerstorage.blob.core.windows.net/custom-order-sketches/e6aabe20-d282-4933-96a3-d99e35213d3f.jpg",
                    AltText = null,
                    IsPrimary = true,
                    DisplayOrder = 0,
                    CreatedAt = new DateTime(2024, 4, 10, 0, 0, 0, DateTimeKind.Utc)
                },

                // Product 13 — Consultation (old Id=9 had image 15)
                new ProductImage
                {
                    Id = 14,
                    ProductId = 13,
                    ImageUrl = "https://stonecarvemanagerstorage.blob.core.windows.net/custom-order-sketches/ae5ccc89-836b-47b0-96b7-6aef332c4ea9.jpg",
                    AltText = null,
                    IsPrimary = true,
                    DisplayOrder = 0,
                    CreatedAt = new DateTime(2024, 4, 15, 0, 0, 0, DateTimeKind.Utc)
                },

                // Product 14 — Maintenance (old Id=6 had no image, reusing available)
                new ProductImage
                {
                    Id = 15,
                    ProductId = 14,
                    ImageUrl = "https://stonecarvemanagerstorage.blob.core.windows.net/product-images/19267379-7a1e-47fb-a7ce-29931f897ad2.png",
                    AltText = null,
                    IsPrimary = true,
                    DisplayOrder = 0,
                    CreatedAt = new DateTime(2024, 4, 20, 0, 0, 0, DateTimeKind.Utc)
                }
            );
        }
    }
}
