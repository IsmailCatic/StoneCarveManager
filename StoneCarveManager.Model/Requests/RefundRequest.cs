namespace StoneCarveManager.Model.Requests
{
    public class RefundRequest
    {
        public string PaymentIntentId { get; set; } = string.Empty;
        public int OrderId { get; set; }
        public decimal? Amount { get; set; } // null = full refund
        public string? Reason { get; set; }
    }
}
