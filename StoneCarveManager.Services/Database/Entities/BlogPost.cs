using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.Database.Entities
{
    public class BlogPost
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
        public string? Summary { get; set; }
        public string? FeaturedImageUrl { get; set; }
        public bool IsPublished { get; set; } = false;

        public bool IsTutorial { get; set; } = false;

        public int ViewCount { get; set; } = 0;

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? PublishedAt { get; set; }

        public DateTime? UpdatedAt { get; set; }

        // Foreign Key - Author
        public int AuthorId { get; set; }
        public User Author { get; set; } = null!;
        public ICollection<BlogImage> Images { get; set; } = new List<BlogImage>();
        public int CategoryId { get; set; }
        public BlogCategory Category { get; set; } = null!;
    }
}
