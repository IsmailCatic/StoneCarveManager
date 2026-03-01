using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.Database.Entities
{
    public class Order
    {
        public int Id { get; set; }

        public DateTime OrderDate { get; set; } = DateTime.UtcNow;

        public string OrderNumber { get; set; } = string.Empty;

        public OrderStatus Status { get; set; } = OrderStatus.Pending;
        public decimal TotalAmount { get; set; }
        // : Customer notes (description of idea, special requests)
        public string? CustomerNotes { get; set; }
        // Internal notes for the employees
        public string? AdminNotes { get; set; }
        // Client Sketch
        public string? AttachmentUrl { get; set; }
        public DateTime? EstimatedCompletionDate { get; set; }
        public DateTime? CompletedAt { get; set; }
        // Customer who placed the order
        public int UserId { get; set; }
        public User User { get; set; } = null!;
        public int? AssignedEmployeeId { get; set; }
        public User? AssignedEmployee { get; set; }

        /// <summary>
        /// For service requests: the catalog service product the customer is requesting.
        /// Null for freeform custom orders.
        /// </summary>
        public int? ServiceProductId { get; set; }
        public Product? ServiceProduct { get; set; }

        /// <summary>
        /// "custom_order" | "service_request" | "standard" (default)
        /// </summary>
        public string OrderType { get; set; } = "standard";

        // Navigation property for OrderItems
        public ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();
        public ICollection<OrderStatusHistory> StatusHistory { get; set; } = new List<OrderStatusHistory>();
        public ICollection<OrderProgressImage> ProgressImages { get; set; } = new List<OrderProgressImage>();
        public Payment? Payment { get; set; }

        // Order review (1:1)
        public ProductReview? Review { get; set; }
        // Delivery details (simplified for a local business)
        public string? DeliveryAddress { get; set; }

        public string? DeliveryCity { get; set; }

        public string? DeliveryZipCode { get; set; }

        public DateTime? DeliveryDate { get; set; }

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
