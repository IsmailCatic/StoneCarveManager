using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Model.Requests
{
    public class OrderProgressImageUploadRequest
    {
        public IFormFile File { get; set; }
        public string? Description { get; set; }
        public int? UploadedByUserId { get; set; } // ili dobavi iz tokena/session-a
    }
}
