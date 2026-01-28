using System.ComponentModel.DataAnnotations;

namespace StoneCarveManager.Model.Requests
{
    public class BlogPostUpdateRequest
    {
        [StringLength(200, MinimumLength = 5)]
        public string? Title { get; set; }

        [StringLength(10000, MinimumLength = 10)]
        public string? Content { get; set; }

        [StringLength(500)]
        public string? Summary { get; set; }

        public string? FeaturedImageUrl { get; set; }

        public bool? IsPublished { get; set; }

        public bool? IsTutorial { get; set; }

        public bool? IsActive { get; set; }

        public int? AuthorId { get; set; }
        public int? CategoryId { get; set; }
    }
}
