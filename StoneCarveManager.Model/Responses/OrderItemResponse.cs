using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Model.Responses
{
    public class OrderItemResponse
    {
        public int Id { get; set; }

        public int ProductId { get; set; }

        public string? ProductName { get; set; }

        public int Quantity { get; set; }

        public decimal UnitPrice { get; set; }

        public decimal TotalPrice { get; set; }

        public decimal Discount { get; set; }
        public string? Specifications { get; set; }

        public string? ProductState { get; set; }  // "custom_order", "available", "portfolio", e

        /// <summary>
        /// Reference/sketch image URLs for custom orders and service requests.
        /// Populated from ProductImages linked to the custom product created for this order item.
        /// </summary>
        public List<string> ReferenceImageUrls { get; set; } = new();
    }

}
