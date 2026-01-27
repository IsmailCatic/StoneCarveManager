using StoneCarveManager.Model.SearchObjects;

namespace StoneCarveManager.Model.SearchObjects
{
    public class RoleSearchObject : BaseSearchObject
    {
        // Keep search object small: FTS inherited, only IsActive filter
        public bool? IsActive { get; set; }
    }
}