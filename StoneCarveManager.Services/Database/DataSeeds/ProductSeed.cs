using Microsoft.EntityFrameworkCore;
using StoneCarveManager.Services.Database.Entities;
using System;

namespace StoneCarveManager.Services.Database.DataSeeds
{
    internal static class ProductSeed
    {
        public static void Seed(ModelBuilder builder)
        {
            builder.Entity<Product>().HasData(

                // ── Garden Decorations (CategoryId = 2) ──────────────────────────
                new Product
                {
                    Id = 1,
                    Name = "Small Crest",
                    Description = "Beautiful hand-carved small crest in white marble, perfect for garden decoration",
                    Price = 1250.00m,
                    StockQuantity = 4,
                    Dimensions = "30cm x 40cm x 2cm",
                    Weight = 85.5m,
                    EstimatedDays = 14,
                    IsInPortfolio = true,
                    ProductState = "active",
                    CategoryId = 2,
                    MaterialId = 1,
                    CreatedAt = new DateTime(2024, 1, 15, 0, 0, 0, DateTimeKind.Utc)
                },
                new Product
                {
                    Id = 2,
                    Name = "Garden Bench",
                    Description = "Elegant curved stone bench for gardens and parks",
                    Price = 750.00m,
                    StockQuantity = 5,
                    Dimensions = "180cm x 60cm x 45cm",
                    Weight = 200.0m,
                    EstimatedDays = 10,
                    IsInPortfolio = false,
                    ProductState = "active",
                    CategoryId = 2,
                    MaterialId = 2,
                    CreatedAt = new DateTime(2024, 2, 1, 0, 0, 0, DateTimeKind.Utc)
                },

                // ── Fountains (CategoryId = 3) ────────────────────────────────────
                new Product
                {
                    Id = 3,
                    Name = "Tiered Fountain",
                    Description = "Three-tier decorative water fountain in travertine",
                    Price = 2500.00m,
                    StockQuantity = 1,
                    Dimensions = "150cm diameter x 200cm height",
                    Weight = 350.0m,
                    EstimatedDays = 30,
                    IsInPortfolio = true,
                    ProductState = "active",
                    CategoryId = 3,
                    MaterialId = 5,
                    CreatedAt = new DateTime(2024, 2, 10, 0, 0, 0, DateTimeKind.Utc)
                },
                new Product
                {
                    Id = 4,
                    Name = "Wall Fountain",
                    Description = "Elegant wall-mounted fountain with lion head design",
                    Price = 980.00m,
                    StockQuantity = 4,
                    Dimensions = "60cm x 40cm x 30cm",
                    Weight = 55.0m,
                    EstimatedDays = 12,
                    IsInPortfolio = true,
                    ProductState = "portfolio",
                    CategoryId = 3,
                    MaterialId = 1,
                    CreatedAt = new DateTime(2024, 2, 15, 0, 0, 0, DateTimeKind.Utc),
                    PortfolioDescription = "Two wall-mounted lion-head fountains commissioned as a matched pair for a private garden in Sarajevo. The pieces were designed to flank an outdoor seating area and integrate with existing white marble stonework.",
                    ClientChallenge = "The client needed two matching fountain units that would complement an existing marble feature wall without overpowering it. Smooth, polished surfaces were specified to match the surrounding stonework.",
                    OurSolution = "Both fountains were carved from the same block of white Carrara marble to ensure an exact colour and grain match. Surfaces were hand-polished to a mirror finish and fitted with concealed pump housings.",
                    ProjectOutcome = "Delivered on schedule and installed in a single day. The client noted the fountains exceeded expectations and reported strong positive feedback from guests.",
                    Location = "Sarajevo, Bosnia and Herzegovina",
                    CompletionYear = 2024,
                    ProjectDuration = 17,
                    TechniquesUsed = "Hand-carving, matched-block selection, mirror-polish finishing, concealed pump fitting"
                },

                // ── Architectural Elements (CategoryId = 4) ───────────────────────
                new Product
                {
                    Id = 5,
                    Name = "Stone Balustrade",
                    Description = "Decorative balustrade section (per meter)",
                    Price = 420.00m,
                    StockQuantity = 20,
                    Dimensions = "100cm x 15cm x 80cm",
                    Weight = 65.0m,
                    EstimatedDays = 8,
                    IsInPortfolio = true,
                    ProductState = "portfolio",
                    CategoryId = 4,
                    MaterialId = 3,
                    CreatedAt = new DateTime(2024, 2, 25, 0, 0, 0, DateTimeKind.Utc),
                    PortfolioDescription = "Three limestone balustrade sections crafted for a garden terrace in Sarajevo, designed to complement the client's existing honed stonework and provide a classical border to a raised planting area.",
                    ClientChallenge = "The client needed balustrade sections that matched the tone and texture of existing stone already laid on the terrace. Standard off-the-shelf options were either the wrong material or finish.",
                    OurSolution = "We sourced matching limestone from the same quarry region as the existing stone and applied a consistent honed finish across all three sections, ensuring visual continuity.",
                    ProjectOutcome = "All three sections were delivered and installed in a single visit. The finish match was exact and the client confirmed the new sections are indistinguishable from the original stonework.",
                    Location = "Sarajevo, Bosnia and Herzegovina",
                    CompletionYear = 2026,
                    ProjectDuration = 15,
                    TechniquesUsed = "Limestone cutting, honed surface finishing, precision jointing"
                },
                new Product
                {
                    Id = 6,
                    Name = "High Relief Panel",
                    Description = "Majestic high relief carved from limestone",
                    Price = 1850.00m,
                    StockQuantity = 2,
                    Dimensions = "90cm x 70cm x 50cm",
                    Weight = 120.0m,
                    EstimatedDays = 21,
                    IsInPortfolio = true,
                    ProductState = "portfolio",
                    CategoryId = 4,
                    MaterialId = 3,
                    CreatedAt = new DateTime(2024, 1, 20, 0, 0, 0, DateTimeKind.Utc),
                    PortfolioDescription = "A high relief limestone panel commissioned for the entrance hall of a private villa in Mostar. The design draws on classical Baroque motifs with a custom figurative centrepiece requested by the client.",
                    ClientChallenge = "The client required a statement piece for a double-height entrance hall — something that conveyed craftsmanship and permanence. The design had to be original, not adapted from a template.",
                    OurSolution = "Our master carver produced an original design sketch in consultation with the client, then executed the full relief in three stages: background removal, mid-ground roughing, and final figure detailing with a matte finish.",
                    ProjectOutcome = "The panel was installed as the focal wall of the entrance hall and received significant attention during a subsequent architectural feature on the property.",
                    Location = "Mostar, Bosnia and Herzegovina",
                    CompletionYear = 2026,
                    ProjectDuration = 31,
                    TechniquesUsed = "High relief carving, figure sculpting, matte surface finishing, limestone work"
                },

                // ── Stone Columns (CategoryId = 7, child of Architectural Elements) ─
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
                    ProductState = "active",
                    CategoryId = 7,
                    MaterialId = 1,
                    CreatedAt = new DateTime(2024, 2, 20, 0, 0, 0, DateTimeKind.Utc)
                },

                // ── Relief Carvings (CategoryId = 5) ─────────────────────────────
                new Product
                {
                    Id = 8,
                    Name = "Geometric Wall Panel",
                    Description = "Hand-carved geometric relief panel ideal for interior decoration",
                    Price = 400.00m,
                    StockQuantity = 15,
                    Dimensions = "30x30x2.5 cm",
                    Weight = 3500.0m,
                    EstimatedDays = 7,
                    IsInPortfolio = true,
                    ProductState = "active",
                    CategoryId = 5,
                    MaterialId = 1,
                    CreatedAt = new DateTime(2024, 3, 1, 0, 0, 0, DateTimeKind.Utc)
                },
                new Product
                {
                    Id = 9,
                    Name = "Floral Stone Relief Panel",
                    Description = "Decorative floral bas-relief panel suitable for villas and gardens",
                    Price = 440.00m,
                    StockQuantity = 10,
                    Dimensions = "40x30x3 cm",
                    Weight = 5500.0m,
                    EstimatedDays = 6,
                    IsInPortfolio = true,
                    ProductState = "active",
                    CategoryId = 5,
                    MaterialId = 1,
                    CreatedAt = new DateTime(2024, 3, 5, 0, 0, 0, DateTimeKind.Utc)
                },

                // ── Services (null CategoryId / MaterialId) ───────────────────────
                new Product
                {
                    Id = 10,
                    Name = "Restoration",
                    Description = "Restoring damaged or aged stone work",
                    Price = 750.00m,
                    StockQuantity = 0,
                    EstimatedDays = 10,
                    IsInPortfolio = false,
                    ProductState = "service",
                    CategoryId = null,
                    MaterialId = null,
                    CreatedAt = new DateTime(2024, 4, 1, 0, 0, 0, DateTimeKind.Utc)
                },
                new Product
                {
                    Id = 11,
                    Name = "Custom Design & Fabrication",
                    Description = "Creating custom stone pieces from client specifications",
                    Price = 2500.00m,
                    StockQuantity = 0,
                    EstimatedDays = 30,
                    IsInPortfolio = false,
                    ProductState = "service",
                    CategoryId = null,
                    MaterialId = null,
                    CreatedAt = new DateTime(2024, 4, 5, 0, 0, 0, DateTimeKind.Utc)
                },
                new Product
                {
                    Id = 12,
                    Name = "Installation",
                    Description = "Installing stone products (countertops, monuments, architectural elements)",
                    Price = 250.00m,
                    StockQuantity = 0,
                    EstimatedDays = 5,
                    IsInPortfolio = false,
                    ProductState = "service",
                    CategoryId = null,
                    MaterialId = null,
                    CreatedAt = new DateTime(2024, 4, 10, 0, 0, 0, DateTimeKind.Utc)
                },
                new Product
                {
                    Id = 13,
                    Name = "Consultation",
                    Description = "Design consultation and material selection",
                    Price = 150.00m,
                    StockQuantity = 0,
                    EstimatedDays = 1,
                    IsInPortfolio = false,
                    ProductState = "service",
                    CategoryId = null,
                    MaterialId = null,
                    CreatedAt = new DateTime(2024, 4, 15, 0, 0, 0, DateTimeKind.Utc)
                },
                new Product
                {
                    Id = 14,
                    Name = "Maintenance",
                    Description = "Ongoing care and maintenance of stone installations",
                    Price = 980.00m,
                    StockQuantity = 0,
                    EstimatedDays = 1,
                    IsInPortfolio = false,
                    ProductState = "service",
                    CategoryId = null,
                    MaterialId = null,
                    CreatedAt = new DateTime(2024, 4, 20, 0, 0, 0, DateTimeKind.Utc)
                },

                // ── service_request work product for Order 18 ─────────────────────
                new Product
                {
                    Id = 23,
                    Name = "Installation - 20260302",
                    Description = "The installation I need is to be done well and thers 40 panels to be installed at a tall height.",
                    Price = 250.00m,
                    StockQuantity = 0,
                    EstimatedDays = 5,
                    IsInPortfolio = false,
                    ProductState = "custom_order",
                    CategoryId = null,
                    MaterialId = null,
                    CreatedAt = new DateTime(2026, 3, 2, 16, 8, 21, DateTimeKind.Utc)
                }
            );
        }
    }
}
