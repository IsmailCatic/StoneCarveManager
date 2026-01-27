using System.ComponentModel.DataAnnotations;

namespace StoneCarveManager.Model.Requests
{
    public class ProductReviewUpdateRequest
    {
        [Range(1, 5)]
        public int? Rating { get; set; }

        [StringLength(1000, MinimumLength = 5)]
        public string? Comment { get; set; }

        public bool? IsApproved { get; set; }
    }
}
