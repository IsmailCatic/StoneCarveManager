using Microsoft.AspNetCore.Http;
using System.ComponentModel.DataAnnotations;

namespace StoneCarveManager.Model.Requests
{
    /// <summary>
    /// Request model for uploading category images
    /// </summary>
    public class CategoryImageUploadRequest
    {
        /// <summary>
        /// Image file (JPEG, PNG)
        /// </summary>
        [Required]
        public IFormFile File { get; set; } = null!;

        /// <summary>
        /// Optional description/alt text for the image
        /// </summary>
        [StringLength(200)]
        public string? AltText { get; set; }
    }
}
