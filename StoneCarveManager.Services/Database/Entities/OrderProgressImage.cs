using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.Database.Entities
{
    public class OrderProgressImage
    {
        public int Id { get; set; }
        public string ImageUrl { get; set; } = string.Empty;
        public string? Description { get; set; }

        public DateTime UploadedAt { get; set; } = DateTime.UtcNow;

        // Foreign Key
        public int OrderId { get; set; }
        public Order Order { get; set; } = null!;

        // Who uploaded (employee)
        public int? UploadedByUserId { get; set; }
        public User? UploadedByUser { get; set; }
    }
}
