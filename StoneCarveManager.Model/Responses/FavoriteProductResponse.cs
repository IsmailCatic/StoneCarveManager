using System;

namespace StoneCarveManager.Model.Responses
{
    public class FavoriteProductResponse
    {
        public int Id { get; set; }
        public int ProductId { get; set; }
        public int UserId { get; set; }
        public DateTime AddedAt { get; set; }
        
        // Optional: Include product details for convenience
        public ProductResponse? Product { get; set; }
    }
}
