using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Model.Requests
{
    public class OrderInsertRequest
    {
        public int UserId { get; set; }

        public int? AssignedEmployeeId { get; set; }

        public string? CustomerNotes { get; set; }

        public string? AdminNotes { get; set; }

        public string? AttachmentUrl { get; set; }

        public DateTime? EstimatedCompletionDate { get; set; }

        public string? DeliveryAddress { get; set; }

        public string? DeliveryCity { get; set; }

        public string? DeliveryZipCode { get; set; }

        public DateTime? DeliveryDate { get; set; }

        public List<OrderItemInsertRequest> Items { get; set; } = new();
    }
}
