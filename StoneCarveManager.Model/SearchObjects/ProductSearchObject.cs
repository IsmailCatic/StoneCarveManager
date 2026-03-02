using StoneCarveManager.Model.SearchObjects;

namespace StoneCarveManager.Model.SearchObjects
{
    public class ProductSearchObject : BaseSearchObject
    {
        public int? CategoryId { get; set; }
        public int? MaterialId { get; set; }
        public bool? IsActive { get; set; }
        public string? ProductState { get; set; }
        
        /// <summary>
        /// Exclude products with this ProductState value (e.g., "custom_order")
        /// </summary>
        public string? ProductStateExclude { get; set; }
        
        /// <summary>
        /// Sort order: "price_asc", "price_desc", "name_asc", "name_desc", "newest", "oldest", "popular"
        /// </summary>
        public string? SortBy { get; set; }
        
        /// <summary>
        /// Minimum price filter
        /// </summary>
        public decimal? MinPrice { get; set; }
        
        /// <summary>
        /// Maximum price filter
        /// </summary>
        public decimal? MaxPrice { get; set; }
        
        /// <summary>
        /// Filter by category name (for portfolio)
        /// </summary>
        public string? CategoryName { get; set; }
        
        /// <summary>
        /// Filter by completion year (for portfolio)
        /// </summary>
        public int? CompletionYear { get; set; }

        /// <summary>
        /// Accepts ?searchQuery=... — desktop clients
        /// </summary>
        public string? SearchQuery { get; set; }

        /// <summary>
        /// Accepts ?search=... — mobile clients
        /// </summary>
        public string? Search { get; set; }

        /// <summary>
        /// Resolved search term: Search ? SearchQuery ? FTS (in priority order).
        /// </summary>
        public string? ResolvedSearch => Search ?? SearchQuery ?? FTS;
    }
}
