using System.ComponentModel.DataAnnotations;

namespace StoneCarveManager.Model.Requests
{
    public class BlogCategoryUpdateRequest
    {
        [StringLength(100, MinimumLength = 2)]
        public string? Name { get; set; }
    }
}