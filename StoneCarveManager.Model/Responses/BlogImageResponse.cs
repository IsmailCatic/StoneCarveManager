using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Model.Responses
{
    public class BlogImageResponse
    {
        public int Id { get; set; }
        public string ImageUrl { get; set; }
        public string? AltText { get; set; }
        public int DisplayOrder { get; set; }
        public DateTime UploadedAt { get; set; }
        public int BlogPostId { get; set; }
    }
}
