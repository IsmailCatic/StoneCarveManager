using System.ComponentModel.DataAnnotations;

namespace StoneCarveManager.Model.Requests
{
    public class BlogPostInsertRequest
    {
        [Required]
        [StringLength(200, MinimumLength = 5)]
        public string Title { get; set; } = string.Empty;

        [Required]
        [StringLength(10000, MinimumLength = 10)]
        public string Content { get; set; } = string.Empty;

        [StringLength(500)]
        public string? Summary { get; set; }

        public string? FeaturedImageUrl { get; set; }

        public bool IsPublished { get; set; } = false;

        public bool IsTutorial { get; set; } = false;

        public bool IsActive { get; set; } = true;

        [Required]
        public int AuthorId { get; set; }
    }
}
