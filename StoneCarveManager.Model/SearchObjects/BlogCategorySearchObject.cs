using StoneCarveManager.Model.SearchObjects;

namespace StoneCarveManager.Model.SearchObjects
{
    public class BlogCategorySearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public bool? IsActive { get; set; }
    }
}