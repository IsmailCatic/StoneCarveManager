using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.Database.Entities
{
    public class OrderStatusHistory
    {
        public int Id { get; set; }
        public OrderStatus OldStatus { get; set; }
        public OrderStatus NewStatus { get; set; }

        public string? Comment { get; set; }
        public DateTime ChangedAt { get; set; } = DateTime.UtcNow;

        // Foreign Keys
        public int OrderId { get; set; }
        public Order Order { get; set; } = null!;

        public int? ChangedByUserId { get; set; }
        public User? ChangedByUser { get; set; }
    }
}
