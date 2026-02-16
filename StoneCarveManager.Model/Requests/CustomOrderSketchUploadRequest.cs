using Microsoft.AspNetCore.Http;
using System.ComponentModel.DataAnnotations;

namespace StoneCarveManager.Model.Requests
{
    /// <summary>
    /// Request model for uploading custom order reference sketches/images
    /// Used BEFORE creating the actual custom order
    /// </summary>
    public class CustomOrderSketchUploadRequest
    {
        /// <summary>
        /// Image file (JPEG, PNG, PDF)
        /// </summary>
        [Required]
        public IFormFile File { get; set; } = null!;

        /// <summary>
        /// Optional description of the sketch
        /// </summary>
        [StringLength(500)]
        public string? Description { get; set; }
    }
}
