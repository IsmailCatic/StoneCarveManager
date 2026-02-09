using StoneCarveManager.Model.Requests;
using System;

namespace StoneCarveManager.Model.Responses
{
    public class OrderStatusHistoryResponse
    {
        public int Id { get; set; }
        
        public OrderStatus OldStatus { get; set; }
        
        public OrderStatus NewStatus { get; set; }
        
        public string? Comment { get; set; }
        
        public DateTime ChangedAt { get; set; }
        
        public int OrderId { get; set; }
        
        public int? ChangedByUserId { get; set; }
        
        public string? ChangedByUserName { get; set; } // Full name of user who changed status
        
        // Friendly status names for UI display
        public string OldStatusDisplay => GetStatusDisplay(OldStatus);
        public string NewStatusDisplay => GetStatusDisplay(NewStatus);
        
        private static string GetStatusDisplay(OrderStatus status)
        {
            return status switch
            {
                OrderStatus.Pending => "Requested",
                OrderStatus.Processing => "In the making",
                OrderStatus.Shipped => "Shipped",
                OrderStatus.Delivered => "Delivered",
                OrderStatus.Cancelled => "Cancelled",
                OrderStatus.Returned => "Returned",
                _ => status.ToString()
            };
        }
    }
}
    