using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Model.Requests
{
    public class CategoryInsertRequest
    {
        [Required]
        [StringLength(100, MinimumLength = 2)]
        public string Name { get; set; } = string.Empty;

        [StringLength(500)]
        public string Description { get; set; } = string.Empty;

        public string? ImageUrl { get; set; }
        public bool IsActive { get; set; } = true;
        
        // ✅ Support for hierarchical categories (subcategories)
        public int? ParentCategoryId { get; set; }
    }
}
