using System;

namespace StoneCarveManager.Model.Responses
{
    public class BlogPostResponse
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
        public string? Summary { get; set; }
        public string? FeaturedImageUrl { get; set; }
        public bool IsPublished { get; set; }
        public bool IsTutorial { get; set; }
        public int ViewCount { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? PublishedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public int AuthorId { get; set; }
        public string? AuthorName { get; set; }
        public List<BlogImageResponse> Images { get; set; } = new();
    }
}
