using System.ComponentModel.DataAnnotations;

namespace StoneCarveManager.Model.Requests
{
    public class ProductReviewInsertRequest
    {
        [Required]
        [Range(1, 5)]
        public int Rating { get; set; }

        [Required]
        [StringLength(1000, MinimumLength = 5)]
        public string Comment { get; set; } = string.Empty;

        [Required]
        public int UserId { get; set; }

        public int? ProductId { get; set; }

        public int? OrderId { get; set; }

        public bool IsApproved { get; set; } = true;
    }
}
