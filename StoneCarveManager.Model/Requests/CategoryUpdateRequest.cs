using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Model.Requests
{
    public class CategoryUpdateRequest
    {
        [StringLength(100, MinimumLength = 2)]
        public string? Name { get; set; }

        [StringLength(500)]
        public string? Description { get; set; }

        public string? ImageUrl { get; set; }
        public bool? IsActive { get; set; }
        
        // ✅ Support for hierarchical categories (move to different parent)
        public int? ParentCategoryId { get; set; }
    }
}
