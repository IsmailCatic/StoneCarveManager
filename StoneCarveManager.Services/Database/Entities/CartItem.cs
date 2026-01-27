using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.Database.Entities
{
    public class CartItem
    {
        public int Id { get; set; }
        public int Quantity { get; set; } = 1;
        public DateTime AddedAt { get; set; } = DateTime.UtcNow;

        public DateTime? UpdatedAt { get; set; }
        public string? CustomNotes { get; set; }

        // Cart that this item belongs to
        public int CartId { get; set; }
        public Cart Cart { get; set; } = null!;

        // Product in the cart
        public int ProductId { get; set; }
        public Product Product { get; set; } = null!;
    }
}
