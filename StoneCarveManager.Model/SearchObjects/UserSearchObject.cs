using StoneCarveManager.Model.SearchObjects;

namespace StoneCarveManager.Model.SearchObjects
{
    public class UserSearchObject : BaseSearchObject
    {
        /// <summary>
        /// Filter by email address (partial match)
        /// </summary>
        public string? Email { get; set; }
        
        /// <summary>
        /// Filter by first name (partial match)
        /// </summary>
        public string? FirstName { get; set; }
        
        /// <summary>
        /// Filter by last name (partial match)
        /// </summary>
        public string? LastName { get; set; }
        
        /// <summary>
        /// Filter by role name (e.g., "Admin", "Employee", "User")
        /// </summary>
        public string? RoleName { get; set; }
    }
}