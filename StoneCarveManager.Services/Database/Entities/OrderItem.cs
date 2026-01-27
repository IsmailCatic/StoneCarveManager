using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.Database.Entities
{
    public class OrderItem
    {
        public int Id { get; set; }
        public int Quantity { get; set; } = 1;

        public decimal UnitPrice { get; set; }

        public decimal Discount { get; set; } = 0;
        // Order that this item belongs to
        public int OrderId { get; set; }
        public Order Order { get; set; } = null!;

        // Product that was ordered
        public int ProductId { get; set; }
        public Product Product { get; set; } = null!;

        // Calculated total for this item
        public decimal Total => Quantity * UnitPrice - Discount;
    }
}
