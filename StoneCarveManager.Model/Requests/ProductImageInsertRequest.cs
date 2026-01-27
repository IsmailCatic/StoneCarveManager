using System.ComponentModel.DataAnnotations;

namespace StoneCarveManager.Model.Requests
{
    public class ProductImageInsertRequest
    {
        [Required]
        [StringLength(500)]
        public string ImageUrl { get; set; } = string.Empty;

        [StringLength(200)]
        public string? AltText { get; set; }

        public bool IsPrimary { get; set; } = false;

        [Range(0, int.MaxValue)]
        public int DisplayOrder { get; set; } = 0;

        [Required]
        public int ProductId { get; set; }
    }
}
