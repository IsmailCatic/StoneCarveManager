using Microsoft.EntityFrameworkCore;
using StoneCarveManager.Services.Database.Entities;
using System;

namespace StoneCarveManager.Services.Database.DataSeeds
{
    internal static class BlogCategorySeed
    {
        public static void Seed(ModelBuilder builder)
        {
            builder.Entity<BlogCategory>().HasData(
                new BlogCategory
                {
                    Id = 1,
                    Name = "History",
                    IsActive = true,
                    CreatedAt = new DateTime(2026, 1, 28, 18, 34, 48, DateTimeKind.Utc)
                },
                new BlogCategory
                {
                    Id = 2,
                    Name = "Materials",
                    IsActive = true,
                    CreatedAt = new DateTime(2026, 1, 28, 18, 35, 19, DateTimeKind.Utc)
                },
                new BlogCategory
                {
                    Id = 3,
                    Name = "Techniques",
                    IsActive = true,
                    CreatedAt = new DateTime(2026, 1, 28, 18, 37, 1, DateTimeKind.Utc)
                },
                new BlogCategory
                {
                    Id = 5,
                    Name = "Intermediates",
                    IsActive = true,
                    CreatedAt = new DateTime(2026, 1, 28, 18, 37, 17, DateTimeKind.Utc)
                },
                new BlogCategory
                {
                    Id = 6,
                    Name = "Advanced",
                    IsActive = true,
                    CreatedAt = new DateTime(2026, 1, 28, 18, 37, 24, DateTimeKind.Utc)
                }
            );
        }
    }
}
