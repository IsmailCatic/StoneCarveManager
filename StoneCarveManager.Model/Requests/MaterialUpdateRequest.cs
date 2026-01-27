using System.ComponentModel.DataAnnotations;

namespace StoneCarveManager.Model.Requests
{
    public class MaterialUpdateRequest
    {
        [StringLength(100, MinimumLength = 2)]
        public string? Name { get; set; }

        [StringLength(500)]
        public string? Description { get; set; }

        public string? ImageUrl { get; set; }

        [Range(0.01, double.MaxValue)]
        public decimal? PricePerUnit { get; set; }

        [StringLength(20)]
        public string? Unit { get; set; }

        [Range(0, int.MaxValue)]
        public int? QuantityInStock { get; set; }

        public bool? IsAvailable { get; set; }

        public bool? IsActive { get; set; }
    }
}
