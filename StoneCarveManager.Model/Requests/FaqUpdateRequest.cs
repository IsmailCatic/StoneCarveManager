using System.ComponentModel.DataAnnotations;

namespace StoneCarveManager.Model.Requests
{
    public class FaqUpdateRequest
    {
        [StringLength(500, MinimumLength = 5)]
        public string? Question { get; set; }

        [StringLength(4000, MinimumLength = 5)]
        public string? Answer { get; set; }

        [StringLength(100)]
        public string? Category { get; set; }

        public int? DisplayOrder { get; set; }

        public bool? IsActive { get; set; }
    }
}
