namespace StoneCarveManager.Model.Requests
{
    public class CheckoutRequest
    {
        public string? DeliveryAddress { get; set; }
        public string? DeliveryCity { get; set; }
        public string? DeliveryZipCode { get; set; }
        public string? DeliveryCountry { get; set; }
        public string? CustomerNotes { get; set; }
        public string PaymentMethod { get; set; } = "stripe";
    }
}
