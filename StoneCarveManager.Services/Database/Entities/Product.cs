using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.Database.Entities
{
    public class Product
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public decimal Price { get; set; }

        public int StockQuantity { get; set; } = 0;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? UpdatedAt { get; set; }

        public string? Dimensions { get; set; }

        // Product weight for shipping calculations (in grams)
        public decimal? Weight { get; set; }
        public int EstimatedDays { get; set; } = 7;
        public bool IsInPortfolio { get; set; } = true;
        public int ViewCount { get; set; } = 0;

        // Category relationship
        public int? CategoryId { get; set; }
        public Category? Category { get; set; }
        
        // Material relationship
        public int? MaterialId { get; set; }
        public Material? Material { get; set; }

        // Navigation property for assets (images)
        public ICollection<ProductImage> Images { get; set; } = new List<ProductImage>();


        // Navigation property for product reviews
        public ICollection<ProductReview> Reviews { get; set; } = new List<ProductReview>();

        // Navigation property for order items
        public ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();

        // Navigation property for cart items
        public ICollection<CartItem> CartItems { get; set; } = new List<CartItem>();
        public string ProductState { get; set; } = "draft";

        // NEW: Portfolio-specific fields
        [StringLength(4000)]
        public string? PortfolioDescription { get; set; }  // Detailed project description

        [StringLength(2000)]
        public string? ClientChallenge { get; set; }  // "The Challenge" section

        [StringLength(2000)]
        public string? OurSolution { get; set; }  // "Our Solution" section

        [StringLength(2000)]
        public string? ProjectOutcome { get; set; }  // "The Outcome" section

        [StringLength(200)]
        public string? Location { get; set; }  // Project location (e.g., "Park Mostar")

        public int? CompletionYear { get; set; }  // Year project was completed

        public int? ProjectDuration { get; set; }  // How many days it took

        [StringLength(500)]
        public string? TechniquesUsed { get; set; }  // "Hand-carved, CNC, 
    }
}
