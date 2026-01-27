using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.Database.Entities
{
    public class ProductReview
    {
        public int Id { get; set; }
        public int Rating { get; set; }
        public string Comment { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // User who wrote the review
        public int UserId { get; set; }
        public User User { get; set; } = null!;

        // Product that was reviewed
        public int? ProductId { get; set; }

        public Product? Product { get; set; }
        public int? OrderId { get; set; }
        public Order? Order { get; set; }

        // Whether the review is approved/visible
        public bool IsApproved { get; set; } = true;
        public DateTime? UpdatedAt { get; set; }
    }
}
