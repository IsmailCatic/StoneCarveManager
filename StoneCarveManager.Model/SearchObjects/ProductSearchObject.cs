using StoneCarveManager.Model.SearchObjects;

namespace StoneCarveManager.Model.SearchObjects
{
    public class ProductSearchObject : BaseSearchObject
    {
        public int? CategoryId { get; set; }
        public int? MaterialId { get; set; }
        public bool? IsActive { get; set; }
        public string? ProductState { get; set; }
    }
}
