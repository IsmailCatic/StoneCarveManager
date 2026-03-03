using Microsoft.EntityFrameworkCore;
using StoneCarveManager.Services.Database.Entities;
using System;

namespace StoneCarveManager.Services.Database.DataSeeds
{
    internal static class BlogPostSeed
    {
        public static void Seed(ModelBuilder builder)
        {
            SeedBlogPosts(builder);
            SeedBlogImages(builder);
        }

        private static void SeedBlogPosts(ModelBuilder builder)
        {
            builder.Entity<BlogPost>().HasData(

                // AuthorId = -999 (Ismail — Admin) — only seeded admin/employee IDs are valid
                new BlogPost
                {
                    Id = 7,
                    Title = "Stone carving for beginners",
                    Summary = "A blog post targeted at people who are looking to start up stone carving.",
                    Content = "Stone Carving for Beginners: A Complete Introduction to the Craft\n\nStone carving is one of the oldest and most respected art forms in human history. From ancient temples to modern architectural details, carved stone has shaped cultures, cities, and artistic traditions for thousands of years.\n\nIf you're curious about starting stone carving, this guide will help you understand the basics, tools, materials, and mindset needed to begin.\n\nWhy Choose Stone Carving?\n\nStone carving combines craftsmanship, patience, and creativity. Unlike many modern materials, stone is permanent. When you carve into it, you are shaping something that can last centuries.\n\nFor beginners, stone carving offers:\nA deep connection to traditional craftsmanship\nA rewarding, hands-on creative process\nThe ability to create architectural and decorative elements\nA skill that can evolve into professional work",
                    FeaturedImageUrl = null,
                    IsPublished = true,
                    IsTutorial = true,
                    IsActive = true,
                    ViewCount = 2,
                    AuthorId = -999,
                    CategoryId = 1,
                    CreatedAt = new DateTime(2026, 1, 31, 15, 57, 58, DateTimeKind.Utc),
                    PublishedAt = new DateTime(2026, 1, 31, 15, 57, 59, DateTimeKind.Utc)
                },
                new BlogPost
                {
                    Id = 8,
                    Title = "Choosing the right stone",
                    Summary = null,
                    Content = "Stone Carving: Choosing the Right Stone\n\nChoosing the right stone is one of the most important steps in stone carving, especially for beginners. The type of stone you select will affect not only the carving process, but also the tools required, the level of detail you can achieve, and the final durability of your artwork.\n\nUnderstanding Stone Hardness\n\nStones vary greatly in hardness, and this determines how easy they are to carve. Softer stones are ideal for beginners because they respond well to basic hand tools and allow mistakes to be corrected more easily. Harder stones require more experience, stronger tools, and greater physical effort.\n\nSoapstone is one of the most popular choices for beginners. It is soft, smooth, and easy to shape, making it perfect for learning basic carving techniques. It also comes in various natural colors, adding visual interest to finished pieces.",
                    FeaturedImageUrl = null,
                    IsPublished = true,
                    IsTutorial = false,
                    IsActive = true,
                    ViewCount = 6,
                    AuthorId = -999,
                    CategoryId = 1,
                    CreatedAt = new DateTime(2026, 2, 1, 17, 8, 15, DateTimeKind.Utc),
                    PublishedAt = new DateTime(2026, 2, 1, 17, 8, 15, DateTimeKind.Utc)
                },
                new BlogPost
                {
                    Id = 12,
                    Title = "Carving a stone column",
                    Summary = null,
                    Content = "Carving a Stone Column: A Step-by-Step Tutorial\n\nStone columns have defined architecture for thousands of years. From classical temples to modern villas, a carved column represents strength, structure, and craftsmanship.\n\nIf you are interested in carving a stone column, this tutorial will guide you through the essential steps, tools, and considerations needed to approach the project properly.\n\nStep 1: Choose the Right Stone\n\nBefore carving begins, selecting the correct material is critical.\n\nFor beginners or intermediate carvers:\nLimestone – easier to carve, consistent texture\nSandstone – workable and durable\nMarble – elegant but slightly harder to shape\n\nAvoid granite unless you have advanced tools and experience.\n\nStep 2: Plan the Column Design\n\nDecide what type of column you are creating and sketch your design with exact measurements.\n\nStep 3: Rough Shaping the Shaft\n\nStart by marking the circular outline on the top and bottom of the stone block. Using a point chisel and mallet, remove excess corners and gradually shape the stone into a rough cylinder.\n\nStep 4: Refining the Shape\n\nSwitch to a tooth chisel to smooth and refine the cylindrical surface. If carving flutes, measure and divide the circumference evenly.\n\nStep 5: Carving the Base and Capital\n\nThe base and capital define the character of the column. Always carve decorative elements after the main structure is balanced.\n\nStep 6: Surface Finishing\n\nUse flat chisels to remove tool marks, smooth with rasps or sanding stones, and apply a finish appropriate to the style.\n\nStep 7: Safety and Structural Considerations\n\nStone columns are heavy. Always work on stable ground, use proper lifting support, and wear eye protection.",
                    FeaturedImageUrl = null,
                    IsPublished = true,
                    IsTutorial = true,
                    IsActive = true,
                    ViewCount = 6,
                    AuthorId = -999,
                    CategoryId = 1,
                    CreatedAt = new DateTime(2026, 2, 24, 21, 2, 19, DateTimeKind.Utc),
                    PublishedAt = new DateTime(2026, 2, 25, 19, 8, 47, DateTimeKind.Utc)
                }
            );
        }

        private static void SeedBlogImages(ModelBuilder builder)
        {
            builder.Entity<BlogImage>().HasData(

                // Post 7 — Stone carving for beginners
                new BlogImage
                {
                    Id = 2,
                    BlogPostId = 7,
                    ImageUrl = "https://stonecarvemanagerstorage.blob.core.windows.net/blog-images/351171f7-410a-4bb6-a18d-fe48d35bed0e.png",
                    AltText = null,
                    DisplayOrder = 0,
                    UploadedAt = new DateTime(2026, 1, 31, 15, 58, 30, DateTimeKind.Utc)
                },

                // Post 8 — Choosing the right stone
                new BlogImage
                {
                    Id = 3,
                    BlogPostId = 8,
                    ImageUrl = "https://stonecarvemanagerstorage.blob.core.windows.net/blog-images/1690b32e-4b56-43bd-bd24-c0a43dbab965.jpg",
                    AltText = null,
                    DisplayOrder = 0,
                    UploadedAt = new DateTime(2026, 2, 1, 17, 10, 41, DateTimeKind.Utc)
                },

                // Post 12 — Carving a stone column
                new BlogImage
                {
                    Id = 5,
                    BlogPostId = 12,
                    ImageUrl = "https://stonecarvemanagerstorage.blob.core.windows.net/blog-images/4443b185-0b08-43b6-97f5-6e2843e369a8.jpg",
                    AltText = null,
                    DisplayOrder = 0,
                    UploadedAt = new DateTime(2026, 2, 24, 21, 3, 6, DateTimeKind.Utc)
                }
            );
        }
    }
}
