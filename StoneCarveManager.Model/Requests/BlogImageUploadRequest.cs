using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Model.Requests
{
    public class BlogImageUploadRequest
    {
        [Required] public IFormFile File { get; set; }
        public string? AltText { get; set; }
        public int DisplayOrder { get; set; } = 0;
    }
}
