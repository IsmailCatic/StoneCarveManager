using System.ComponentModel.DataAnnotations;

namespace StoneCarveManager.Model.Requests
{
    public class ProductInsertRequest
    {
        [Required]
        [StringLength(200, MinimumLength = 2)]
        public string Name { get; set; } = string.Empty;

        [Required]
        [StringLength(2000)]
        public string Description { get; set; } = string.Empty;

        [Required]
        [Range(0.01, double.MaxValue)]
        public decimal Price { get; set; }

        [Range(0, int.MaxValue)]
        public int StockQuantity { get; set; } = 0;

        public bool IsActive { get; set; } = true;

        [StringLength(100)]
        public string? Dimensions { get; set; }

        [Range(0, double.MaxValue)]
        public decimal? Weight { get; set; }

        [Range(1, 365)]
        public int EstimatedDays { get; set; } = 7;

        public bool IsInPortfolio { get; set; } = true;

        public int? CategoryId { get; set; }

        public int? MaterialId { get; set; }
    }
}
