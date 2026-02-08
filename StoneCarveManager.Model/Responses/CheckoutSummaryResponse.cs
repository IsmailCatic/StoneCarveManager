using System.Collections.Generic;

namespace StoneCarveManager.Model.Responses
{
    public class CheckoutSummaryResponse
    {
        public List<CheckoutItemResponse> Items { get; set; } = new();
        public decimal Subtotal { get; set; }
        public decimal Discount { get; set; }
        public decimal DeliveryFee { get; set; }
        public decimal Total { get; set; }
        public int TotalItems { get; set; }
    }

    public class CheckoutItemResponse
    {
        public int ProductId { get; set; }
        public string ProductName { get; set; } = string.Empty;
        public string? ProductImageUrl { get; set; }
        public decimal UnitPrice { get; set; }
        public int Quantity { get; set; }
        public decimal Total { get; set; }
    }
}
