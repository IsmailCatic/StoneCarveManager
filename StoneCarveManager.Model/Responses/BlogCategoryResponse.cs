using System;

namespace StoneCarveManager.Model.Responses
{
    public class BlogCategoryResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public int PostCount { get; set; }
        public DateTime CreatedAt { get; set; } 
        public DateTime? UpdatedAt { get; set; }
    }
}       