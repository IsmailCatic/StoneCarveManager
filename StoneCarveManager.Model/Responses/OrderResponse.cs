using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Model.Responses
{
    using global::StoneCarveManager.Model.Requests;
    using System;
    using System.Collections.Generic;

    namespace StoneCarveManager.Model.Responses
    {
        public class OrderResponse
        {
            public int Id { get; set; }

            public DateTime OrderDate { get; set; }

            public string OrderNumber { get; set; } = string.Empty;

            public OrderStatus Status { get; set; }

            //public decimal TotalAmount { get; set; }
            public decimal TotalAmount => OrderItems.Sum(i => i.TotalPrice);

            public string? CustomerNotes { get; set; }

            public string? AdminNotes { get; set; }

            public string? AttachmentUrl { get; set; }

            public DateTime? EstimatedCompletionDate { get; set; }

            public DateTime? CompletedAt { get; set; }

            public int UserId { get; set; }

            public int? AssignedEmployeeId { get; set; }
            
            public string? AssignedEmployeeName { get; set; }

            /// <summary>
            /// For service requests: the catalog service product the customer requested.
            /// </summary>
            public int? ServiceProductId { get; set; }

            /// <summary>
            /// "standard" | "custom_order" | "service_request"
            /// </summary>
            public string OrderType { get; set; } = "standard";

            public List<OrderItemResponse> OrderItems { get; set; } = new();

            public string? DeliveryAddress { get; set; }

            public string? DeliveryCity { get; set; }

            public string? DeliveryZipCode { get; set; }

            public string? DeliveryCountry { get; set; }

            public DateTime? DeliveryDate { get; set; }

            public string? ClientName { get; set; }
            public string? ClientEmail { get; set; }
            public ProductReviewResponse? Review { get; set; }

            public List<OrderProgressImageResponse> ProgressImages { get; set; } = new();
            
            // Status history timeline for tracking order progress
            public List<OrderStatusHistoryResponse> StatusHistory { get; set; } = new();
        }
    }
}
