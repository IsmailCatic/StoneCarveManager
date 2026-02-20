using Microsoft.AspNetCore.Http;
using System.ComponentModel.DataAnnotations;

namespace StoneCarveManager.Model.Requests
{
    public class UserProfileImageUploadRequest
    {
        [Required]
        public IFormFile File { get; set; } = null!;

        [StringLength(200)]
        public string? AltText { get; set; }
    }
}
