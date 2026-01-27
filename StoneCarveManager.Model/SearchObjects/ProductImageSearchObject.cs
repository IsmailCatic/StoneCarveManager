using StoneCarveManager.Model.SearchObjects;

namespace StoneCarveManager.Model.SearchObjects
{
    public class ProductImageSearchObject : BaseSearchObject
    {
        public int? ProductId { get; set; }
        public bool? IsPrimary { get; set; }
    }
}
