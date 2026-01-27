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
                    Id = 1,
                    Name = "Statues",
                    Description = "Hand-carved stone statues and sculptures",
                    ImageUrl = "/images/categories/statues.jpg",
                    IsActive = true,
                    CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc)
                },
                new Category
                {
                    Id = 2,
                    Name = "Garden Decorations",
                    Description = "Outdoor stone decorations for gardens and parks",
                    ImageUrl = "/images/categories/garden. jpg",
                    IsActive = true,
                    CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc)
                },
                new Category
                {
                    Id = 3,
                    Name = "Fountains",
                    Description = "Decorative stone water fountains",
                    ImageUrl = "/images/categories/fountains. jpg",
                    IsActive = true,
                    CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc)
                },
                new Category
                {
                    Id = 4,
                    Name = "Architectural Elements",
                    Description = "Columns, arches, balustrades and other architectural pieces",
                    ImageUrl = "/images/categories/architectural.jpg",
                    IsActive = true,
                    CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc)
                },
                new Category
                {
                    Id = 5,
                    Name = "Custom Carvings",
                    Description = "Custom stone carving projects",
                    ImageUrl = "/images/categories/custom.jpg",
                    IsActive = true,
                    CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc)
                }
            );
        }
    }
}
