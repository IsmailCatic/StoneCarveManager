using StoneCarveManager.Model.SearchObjects;

namespace StoneCarveManager.Model.SearchObjects
{
    public class ProductReviewSearchObject : BaseSearchObject
    {
        public int? ProductId { get; set; }
        public int? UserId { get; set; }
        public bool? IsApproved { get; set; }
        public int? OrderId { get; set; }
    }
}
