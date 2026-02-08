namespace StoneCarveManager.Model.Responses
{
    public class PaymentIntentResponse
    {
        public string ClientSecret { get; set; } = string.Empty;
        public string PaymentIntentId { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public string Currency { get; set; } = "bam";
        public string Status { get; set; } = string.Empty;
    }
}
