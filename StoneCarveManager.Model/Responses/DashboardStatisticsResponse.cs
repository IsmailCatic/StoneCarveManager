using System;
using System.Collections.Generic;

namespace StoneCarveManager.Model.Responses
{
    public class DashboardStatisticsResponse
    {
        // Revenue
        public decimal TotalRevenue { get; set; }
        public decimal RevenueChange { get; set; } // % change from previous period
        public decimal AverageOrderValue { get; set; }
        
        // Orders
        public int TotalOrders { get; set; }
        public int OrdersChange { get; set; }
        public int PendingOrders { get; set; }
        public int ProcessingOrders { get; set; }
        public int CompletedOrders { get; set; }
        public int CancelledOrders { get; set; }
        public int CustomOrders { get; set; }
        public int RegularOrders { get; set; }
        
        // Customers
        public int TotalCustomers { get; set; }
        public int NewCustomers { get; set; }
        public int ReturningCustomers { get; set; }
        
        // Products
        public int TotalProducts { get; set; }
        public int LowStockProducts { get; set; }
        
        // Reviews
        public double AverageRating { get; set; }
        public int TotalReviews { get; set; }
        public int PendingReviews { get; set; }
        
        // Payments
        public int SuccessfulPayments { get; set; }
        public int FailedPayments { get; set; }
        public decimal RefundedAmount { get; set; }
    }
}
