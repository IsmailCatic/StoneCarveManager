using System.ComponentModel.DataAnnotations;

namespace StoneCarveManager.Model.Requests
{
    public class ProductUpdateRequest
    {
        [StringLength(200, MinimumLength = 2)]
        public string? Name { get; set; }

        [StringLength(2000)]
        public string? Description { get; set; }

        [Range(0.01, double.MaxValue)]
        public decimal? Price { get; set; }

        [Range(0, int.MaxValue)]
        public int? StockQuantity { get; set; }

        public bool? IsActive { get; set; }

        [StringLength(100)]
        public string? Dimensions { get; set; }

        [Range(0, double.MaxValue)]
        public decimal? Weight { get; set; }

        [Range(1, 365)]
        public int? EstimatedDays { get; set; }

        public bool? IsInPortfolio { get; set; }

        public int? CategoryId { get; set; }

        public int? MaterialId { get; set; }

        [StringLength(50)]
        public string? ProductState { get; set; }
    }
}
