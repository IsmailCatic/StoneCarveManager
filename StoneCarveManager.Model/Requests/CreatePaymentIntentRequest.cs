namespace StoneCarveManager.Model.Requests
{
    public class CreatePaymentIntentRequest
    {
        public int OrderId { get; set; }
        public string PaymentMethod { get; set; } = "stripe"; // card, ideal, etc.
        public string? CustomerEmail { get; set; }
        public string? CustomerName { get; set; }
    }
}
