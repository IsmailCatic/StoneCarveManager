using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.Database.Entities
{
    public class Material
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty; // e.g. Marble, Granite, Limestone

        public string Description { get; set; } = string.Empty;

        public string? ImageUrl { get; set; }

        public decimal PricePerUnit { get; set; } // Price per unit

        public string Unit { get; set; } = "m²"; // m², kg, pcs

        public int QuantityInStock { get; set; } = 0;

        public bool IsAvailable { get; set; } = true;

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? UpdatedAt { get; set; }

        // Navigation property
        public ICollection<Product> Products { get; set; } = new List<Product>();
    }
}
