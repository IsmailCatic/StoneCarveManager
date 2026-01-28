using System.ComponentModel.DataAnnotations;

namespace StoneCarveManager.Model.Requests
{
    public class BlogCategoryInsertRequest
    {
        [Required]
        [StringLength(100, MinimumLength = 2)]
        public string Name { get; set; } = string.Empty;
    }
}       