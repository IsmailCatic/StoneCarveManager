using System;

namespace StoneCarveManager.Model.Responses
{
    public class TopCustomerResponse
    {
        public int UserId { get; set; }
        public string CustomerName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public int TotalOrders { get; set; }
        public decimal TotalSpent { get; set; }
        public DateTime LastOrderDate { get; set; }
    }
}
