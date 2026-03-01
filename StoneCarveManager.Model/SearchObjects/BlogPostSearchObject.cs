using StoneCarveManager.Model.SearchObjects;

namespace StoneCarveManager.Model.SearchObjects
{
    public class BlogPostSearchObject : BaseSearchObject
    {
        public bool? IsPublished { get; set; }
        public int? AuthorId { get; set; }
        public int? CategoryId { get; set; }
        public bool? IsTutorial { get; set; }
    }
}
