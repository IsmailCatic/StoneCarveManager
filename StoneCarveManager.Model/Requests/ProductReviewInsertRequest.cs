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

        /// <summary>
        /// UserId is automatically set from JWT token in the controller
        /// No need to send from frontend
        /// </summary>
        public int UserId { get; set; }

        public int? ProductId { get; set; }

        public int? OrderId { get; set; }

        /// <summary>
        /// Default is false - reviews require admin approval
        /// </summary>
        public bool IsApproved { get; set; } = false;
    }
}
