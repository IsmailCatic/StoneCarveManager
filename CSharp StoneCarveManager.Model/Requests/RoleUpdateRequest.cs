using System.ComponentModel.DataAnnotations;

namespace StoneCarveManager.Model.Requests
{
    public class RoleUpdateRequest
    {
        [StringLength(100, MinimumLength = 2)]
        public string? Name { get; set; }

        [StringLength(500)]
        public string? Description { get; set; }

        public bool? IsActive { get; set; }
    }
}