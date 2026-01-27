using StoneCarveManager.Model.SearchObjects;

namespace StoneCarveManager.Model.SearchObjects
{
    public class UserSearchObject : BaseSearchObject
    {
        public string? Email { get; set; }
        public bool? IsActive { get; set; }
        public bool? IsBlocked { get; set; }
        public int? RoleId { get; set; }
    }
}