namespace StoneCarveManager.Model.Responses
{
    public class CheckoutResponse
    {
        public int OrderId { get; set; }
        public string OrderNumber { get; set; } = string.Empty;
        public decimal TotalAmount { get; set; }
        public string PaymentIntentId { get; set; } = string.Empty;
        public string ClientSecret { get; set; } = string.Empty;
        public string PaymentStatus { get; set; } = string.Empty;
    }
}
