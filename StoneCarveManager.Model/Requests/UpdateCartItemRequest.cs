namespace StoneCarveManager.Model.Requests
{
    public class UpdateCartItemRequest
    {
        public int Quantity { get; set; }
        public string? CustomNotes { get; set; }
    }
}
