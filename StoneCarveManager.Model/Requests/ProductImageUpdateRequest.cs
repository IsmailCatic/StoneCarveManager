using System.ComponentModel.DataAnnotations;

namespace StoneCarveManager.Model.Requests
{
    public class ProductImageUpdateRequest
    {
        [StringLength(500)]
        public string? ImageUrl { get; set; }

        [StringLength(200)]
        public string? AltText { get; set; }

        public bool? IsPrimary { get; set; }

        [Range(0, int.MaxValue)]
        public int? DisplayOrder { get; set; }

        public int? ProductId { get; set; }
    }
}
