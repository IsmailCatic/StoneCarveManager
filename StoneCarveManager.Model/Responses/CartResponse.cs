using System;
using System.Collections.Generic;

namespace StoneCarveManager.Model.Responses
{
    public class CartResponse
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string? UserName { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        
        public List<CartItemResponse> Items { get; set; } = new();
        
        // Calculated fields
        public decimal Subtotal { get; set; }
        public decimal TotalDiscount { get; set; }
        public decimal Total { get; set; }
        public int TotalItems { get; set; }
    }
}
