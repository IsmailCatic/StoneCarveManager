using System;

namespace StoneCarveManager.Model.Responses
{
    public class ProductResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public decimal Price { get; set; }
        public int StockQuantity { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public string? Dimensions { get; set; }
        public decimal? Weight { get; set; }
        public int EstimatedDays { get; set; }
        public bool IsInPortfolio { get; set; }
        public int ViewCount { get; set; }
        public int CategoryId { get; set; }
        public string? CategoryName { get; set; }
        public int MaterialId { get; set; }
        public string? MaterialName { get; set; }
        public string ProductState { get; set; } = string.Empty;
        public int ReviewCount { get; set; }
        public double AverageRating { get; set; }
        public List<ProductImageResponse> Images { get; set; } = new();
        public List<ProductReviewResponse> Reviews { get; set; } = new();
    }
}
