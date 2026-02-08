using System;

namespace StoneCarveManager.Model.Responses
{
    public class CartItemResponse
    {
        public int Id { get; set; }
        public int CartId { get; set; }
        public int ProductId { get; set; }
        public string ProductName { get; set; } = string.Empty;
        public string? ProductImageUrl { get; set; }
        public decimal UnitPrice { get; set; }
        public int Quantity { get; set; }
        public decimal Subtotal { get; set; }
        public decimal Discount { get; set; }
        public decimal Total { get; set; }
        public DateTime AddedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public string? CustomNotes { get; set; }
        public bool IsInStock { get; set; }
        public int AvailableStock { get; set; }
    }
}
