using Microsoft.EntityFrameworkCore;
using StoneCarveManager.Services.Database.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.Database.DataSeeds
{
    internal static class CategorySeed
    {
        public static void Seed(ModelBuilder builder)
        {
            builder.Entity<Category>().HasData(
                new Category
                {
                    Id = 2,
                    Name = "Garden Decorations",
                    Description = "Outdoor stone decorations for gardens and parks",
                    ImageUrl = "https://stonecarvemanagerstorage.blob.core.windows.net/category-images/33b6aa98-6812-47f0-a6a5-4a1753ef5470.jpg",
                    ParentCategoryId = null,
                    IsActive = true,
                    CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc)
                },
                new Category
                {
                    Id = 3,
                    Name = "Fountains",
                    Description = "Decorative stone water fountains",
                    ImageUrl = "https://stonecarvemanagerstorage.blob.core.windows.net/category-images/360eb5b6-e82a-4a94-a40e-f8ddbec1120a.jpg",
                    ParentCategoryId = null,
                    IsActive = true,
                    CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc)
                },
                new Category
                {
                    Id = 4,
                    Name = "Architectural Elements",
                    Description = "Columns, arches, balustrades and other architectural pieces",
                    ImageUrl = "https://stonecarvemanagerstorage.blob.core.windows.net/category-images/c0d4d177-d2cf-4ae2-88b2-a7a5b42e9670.jpg",
                    ParentCategoryId = null,
                    IsActive = true,
                    CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc)
                },
                new Category
                {
                    Id = 5,
                    Name = "Relief Carvings",
                    Description = "Decorative relief carved elements",
                    ImageUrl = "https://stonecarvemanagerstorage.blob.core.windows.net/category-images/d3e561a3-e4a8-4a58-b724-44147ecfe9d7.jpg",
                    ParentCategoryId = null,
                    IsActive = true,
                    CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc)
                },
                new Category
                {
                    Id = 7,
                    Name = "Stone Columns",
                    Description = "Stone Column of all types and designs",
                    ImageUrl = "https://stonecarvemanagerstorage.blob.core.windows.net/category-images/06aee848-a7ed-4ced-9a3b-8b7f463afee6.jpg",
                    ParentCategoryId = 4,
                    IsActive = true,
                    CreatedAt = new DateTime(2026, 2, 20, 0, 38, 29, DateTimeKind.Utc)
                }
            );
        }
    }
}
