using System.ComponentModel.DataAnnotations;

namespace StoneCarveManager.Model.Requests
{
    public class MaterialInsertRequest
    {
        [Required]
        [StringLength(100, MinimumLength = 2)]
        public string Name { get; set; } = string.Empty;

        [StringLength(500)]
        public string Description { get; set; } = string.Empty;

        public string? ImageUrl { get; set; }

        [Required]
        [Range(0.01, double.MaxValue)]
        public decimal PricePerUnit { get; set; }

        [Required]
        [StringLength(20)]
        public string Unit { get; set; } = "m²";

        [Range(0, int.MaxValue)]
        public int QuantityInStock { get; set; } = 0;

        public bool IsAvailable { get; set; } = true;

        public bool IsActive { get; set; } = true;
    }
}
