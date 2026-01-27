using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.Database.Entities
{
    public class Category
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;

        public string Description { get; set; } = string.Empty;

        // Parent category id for hierarchical categories (optional)
        public int? ParentCategoryId { get; set; }

        // Navigation property for parent category
        public Category? ParentCategory { get; set; }

        // Navigation property for child categories
        public ICollection<Category> ChildCategories { get; set; } = new List<Category>();
        public string? ImageUrl { get; set; }

        // Navigation property for product categories (many-to-many)

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? UpdatedAt { get; set; }
        //public ICollection<ProductCategory> ProductCategories { get; set; } = new List<ProductCategory>();
        //would mean a many -to-many relationship between Category and Product which is not needed here
        //-------------------------------------------
        // Navigation property for products in this category (one-to-many)
        public ICollection<Product> Products { get; set; } = new List<Product>();
    }
}
