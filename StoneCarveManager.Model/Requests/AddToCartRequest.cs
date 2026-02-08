namespace StoneCarveManager.Model.Requests
{
    public class AddToCartRequest
    {
        public int ProductId { get; set; }
        public int Quantity { get; set; } = 1;
        public string? CustomNotes { get; set; }
    }
}
