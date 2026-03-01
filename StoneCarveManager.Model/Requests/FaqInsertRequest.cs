using System.ComponentModel.DataAnnotations;

namespace StoneCarveManager.Model.Requests
{
    public class FaqInsertRequest
    {
        [Required]
        [StringLength(500, MinimumLength = 5)]
        public string Question { get; set; } = string.Empty;

        [Required]
        [StringLength(4000, MinimumLength = 5)]
        public string Answer { get; set; } = string.Empty;

        [StringLength(100)]
        public string? Category { get; set; }

        public int DisplayOrder { get; set; } = 0;

        public bool IsActive { get; set; } = true;
    }
}
