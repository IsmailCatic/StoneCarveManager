namespace StoneCarveManager.Model.Requests
{
    public class ConfirmPaymentRequest
    {
        public string PaymentIntentId { get; set; } = string.Empty;
        public int OrderId { get; set; }
    }
}
