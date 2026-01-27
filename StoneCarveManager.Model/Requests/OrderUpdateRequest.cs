using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Model.Requests
{
    public class OrderUpdateRequest
    {
        public int? AssignedEmployeeId { get; set; }

        public OrderStatus? Status { get; set; }

        public string? CustomerNotes { get; set; }

        public string? AdminNotes { get; set; }

        public string? AttachmentUrl { get; set; }

        public DateTime? EstimatedCompletionDate { get; set; }

        public DateTime? CompletedAt { get; set; }

        public string? DeliveryAddress { get; set; }

        public string? DeliveryCity { get; set; }

        public string? DeliveryZipCode { get; set; }

        public DateTime? DeliveryDate { get; set; }

        public List<OrderItemUpdateRequest>? Items { get; set; }
    }

     public enum OrderStatus
    {
        Pending,
        Processing,
        Shipped,
        Delivered,
        Cancelled,
        Returned
    }


}
