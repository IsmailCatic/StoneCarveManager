using StoneCarveManager.Model.SearchObjects;

namespace StoneCarveManager.Model.SearchObjects
{
    public class ProductReviewSearchObject : BaseSearchObject
    {
        public int? ProductId { get; set; }
        public int? UserId { get; set; }
        public bool? IsApproved { get; set; }
        public int? OrderId { get; set; }
        public int? Rating { get; set; }
        
        /// <summary>
        /// Search query - maps to FTS for full text search
        /// </summary>
        public string? SearchQuery 
        { 
            get => FTS;
            set => FTS = value;
        }
    }
}
