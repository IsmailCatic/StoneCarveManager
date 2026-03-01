using System;
using System.ComponentModel.DataAnnotations;

namespace StoneCarveManager.Services.Database.Entities
{
    public class Faq
    {
        public int Id { get; set; }

        [Required]
        [MaxLength(500)]
        public string Question { get; set; } = string.Empty;

        [Required]
        [MaxLength(4000)]
        public string Answer { get; set; } = string.Empty;

        /// <summary>
        /// Groups related questions together (e.g. "Ordering", "Shipping", "Materials")
        /// </summary>
        [MaxLength(100)]
        public string? Category { get; set; }

        /// <summary>
        /// Controls display order within a category group. Lower = first.
        /// </summary>
        public int DisplayOrder { get; set; } = 0;

        public bool IsActive { get; set; } = true;

        public int ViewCount { get; set; } = 0;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? UpdatedAt { get; set; }
    }
}
