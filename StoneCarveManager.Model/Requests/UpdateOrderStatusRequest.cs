using System;

namespace StoneCarveManager.Model.Requests
{
    /// <summary>
    /// Request model for updating order status by Admin/Employee
    /// Automatically creates OrderStatusHistory entry
    /// </summary>
    public class UpdateOrderStatusRequest
    {
        /// <summary>
        /// New status to set
        /// </summary>
        public OrderStatus NewStatus { get; set; }
        
        /// <summary>
        /// Optional comment explaining the status change
        /// </summary>
        public string? Comment { get; set; }
    }
}
