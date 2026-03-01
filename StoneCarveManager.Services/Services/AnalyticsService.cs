using Microsoft.EntityFrameworkCore;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.Responses.Analytics;
using StoneCarveManager.Services.Database.Context;
using StoneCarveManager.Services.Database.Entities;
using StoneCarveManager.Services.IServices;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.Services
{
    public class AnalyticsService : IAnalyticsService
    {
        private readonly AppDbContext _context;

        public AnalyticsService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<DashboardStatisticsResponse> GetDashboardStatisticsAsync(
            DateTime startDate,
            DateTime endDate,
            CancellationToken cancellationToken = default)
        {
            // Calculate previous period for comparison
            var periodLength = (endDate - startDate).Days;
            var previousStartDate = startDate.AddDays(-periodLength);
            var previousEndDate = startDate;

            // ? FIX: Use Payments as single source of truth for revenue
            // Current period payments (succeeded + partially_refunded)
            var currentPayments = await _context.Payments
                .Include(p => p.Order)
                .Where(p => (p.Status == "succeeded" || p.Status == "partially_refunded" || p.Status == "refunded") 
                    && p.CreatedAt >= startDate && p.CreatedAt <= endDate)
                .ToListAsync(cancellationToken);

            // Previous period payments
            var previousPayments = await _context.Payments
                .Include(p => p.Order)
                .Where(p => (p.Status == "succeeded" || p.Status == "partially_refunded" || p.Status == "refunded") 
                    && p.CreatedAt >= previousStartDate && p.CreatedAt < previousEndDate)
                .ToListAsync(cancellationToken);

            // Current period orders (for order statistics, not revenue)
            var currentOrders = await _context.Orders
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.Product)
                .Where(o => o.OrderDate >= startDate && o.OrderDate <= endDate)
                .ToListAsync(cancellationToken);

            // Previous period orders
            var previousOrders = await _context.Orders
                .Where(o => o.OrderDate >= previousStartDate && o.OrderDate < previousEndDate)
                .ToListAsync(cancellationToken);

            // ? FIXED: Revenue = Gross Revenue - Total Refunds
            var currentGrossRevenue = currentPayments.Sum(p => p.Amount);
            var currentTotalRefunds = currentPayments.Sum(p => p.RefundAmount ?? 0);
            var currentNetRevenue = currentGrossRevenue - currentTotalRefunds;

            var previousGrossRevenue = previousPayments.Sum(p => p.Amount);
            var previousTotalRefunds = previousPayments.Sum(p => p.RefundAmount ?? 0);
            var previousNetRevenue = previousGrossRevenue - previousTotalRefunds;

            var revenueChange = previousNetRevenue > 0 
                ? ((currentNetRevenue - previousNetRevenue) / previousNetRevenue) * 100 
                : 0;

            // ? Average order value from NET revenue (after refunds)
            var paidOrdersCount = currentPayments.Select(p => p.OrderId).Distinct().Count();
            var averageOrderValue = paidOrdersCount > 0 ? currentNetRevenue / paidOrdersCount : 0;

            // Orders change
            var ordersChange = previousOrders.Count > 0
                ? ((currentOrders.Count - previousOrders.Count) * 100 / previousOrders.Count)
                : 0;

            // Customer statistics - count only users who have actually placed orders
            var customerIdsInPeriod = currentOrders.Select(o => o.UserId).Distinct().ToList();
            
            var totalCustomers = customerIdsInPeriod.Count;
            
            var orderCountsInPeriod = currentOrders
                .GroupBy(o => o.UserId)
                .ToDictionary(g => g.Key, g => g.Count());
            
            var newCustomers = customerIdsInPeriod.Count(userId => 
                orderCountsInPeriod.ContainsKey(userId) && orderCountsInPeriod[userId] == 1);
            
            var returningCustomers = customerIdsInPeriod.Count(userId =>
                orderCountsInPeriod.ContainsKey(userId) && orderCountsInPeriod[userId] > 1);

            // Product statistics
            var totalProducts = await _context.Products.CountAsync(cancellationToken);
            var lowStockProducts = await _context.Products
                .Where(p => p.ProductState == "active" && p.StockQuantity > 0 && p.StockQuantity < 5)
                .CountAsync(cancellationToken);

            // Review statistics
            var reviews = await _context.ProductReviews.ToListAsync(cancellationToken);
            var approvedReviews = reviews.Where(r => r.IsApproved).ToList();
            var averageRating = approvedReviews.Any() 
                ? approvedReviews.Average(r => r.Rating) 
                : 0;

            // Payment statistics
            var payments = await _context.Payments
                .Where(p => p.CreatedAt >= startDate && p.CreatedAt <= endDate)
                .ToListAsync(cancellationToken);

            var successfulPayments = payments.Count(p => p.Status == "succeeded" || p.Status == "partially_refunded");
            var failedPayments = payments.Count(p => p.Status == "failed");
            var refundedAmount = currentTotalRefunds; // Use calculated refund amount

            // Order status counts
            var customOrders = currentOrders.Count(o =>
                o.OrderItems.Any(oi => oi.Product.ProductState == "custom_order"));

            return new DashboardStatisticsResponse
            {
                // ? Revenue (NET Revenue = Gross - Refunds)
                TotalRevenue = currentNetRevenue,
                RevenueChange = revenueChange,
                AverageOrderValue = averageOrderValue,

                // Orders
                TotalOrders = currentOrders.Count,
                OrdersChange = ordersChange,
                PendingOrders = currentOrders.Count(o => o.Status == OrderStatus.Pending),
                ProcessingOrders = currentOrders.Count(o => o.Status == OrderStatus.Processing),
                CompletedOrders = currentOrders.Count(o => o.Status == OrderStatus.Delivered),
                CancelledOrders = currentOrders.Count(o => o.Status == OrderStatus.Cancelled),
                CustomOrders = customOrders,
                RegularOrders = currentOrders.Count - customOrders,

                // Customers (only count actual customers with orders)
                TotalCustomers = totalCustomers,
                NewCustomers = newCustomers,
                ReturningCustomers = returningCustomers,

                // Products
                TotalProducts = totalProducts,
                LowStockProducts = lowStockProducts,

                // Reviews
                AverageRating = averageRating,
                TotalReviews = reviews.Count,
                PendingReviews = reviews.Count(r => !r.IsApproved),

                // Payments
                SuccessfulPayments = successfulPayments,
                FailedPayments = failedPayments,
                RefundedAmount = refundedAmount
            };
        }

        public async Task<List<RevenueByMethodResponse>> GetRevenueByPaymentMethodAsync(
            DateTime? startDate,
            DateTime? endDate,
            CancellationToken cancellationToken = default)
        {
            var query = _context.Payments
                .Where(p => p.Status == "succeeded" || p.Status == "partially_refunded" || p.Status == "refunded");

            if (startDate.HasValue)
                query = query.Where(p => p.CreatedAt >= startDate.Value);

            if (endDate.HasValue)
                query = query.Where(p => p.CreatedAt <= endDate.Value);

            var payments = await query.ToListAsync(cancellationToken);
            
            // ? Calculate NET revenue (gross - refunds)
            var grossRevenue = payments.Sum(p => p.Amount);
            var totalRefunds = payments.Sum(p => p.RefundAmount ?? 0);
            var totalNetRevenue = grossRevenue - totalRefunds;

            var grouped = payments
                .GroupBy(p => p.Method)
                .Select(g => new RevenueByMethodResponse
                {
                    PaymentMethod = g.Key,
                    TotalRevenue = g.Sum(p => p.Amount - (p.RefundAmount ?? 0)), // NET revenue
                    OrderCount = g.Count(),
                    Percentage = totalNetRevenue > 0 ? (g.Sum(p => p.Amount - (p.RefundAmount ?? 0)) / totalNetRevenue) * 100 : 0
                })
                .OrderByDescending(x => x.TotalRevenue)
                .ToList();

            return grouped;
        }

        public async Task<List<RevenueTrendResponse>> GetRevenueTrendAsync(
            DateTime startDate,
            DateTime endDate,
            string groupBy,
            CancellationToken cancellationToken = default)
        {
            var payments = await _context.Payments
                .Include(p => p.Order)
                .Where(p => (p.Status == "succeeded" || p.Status == "partially_refunded" || p.Status == "refunded") 
                    && p.CreatedAt >= startDate && p.CreatedAt <= endDate)
                .ToListAsync(cancellationToken);

            var grouped = groupBy.ToLower() switch
            {
                "day" => payments
                    .GroupBy(p => p.CreatedAt.Date)
                    .Select(g => new RevenueTrendResponse
                    {
                        Date = g.Key,
                        Revenue = g.Sum(p => p.Amount - (p.RefundAmount ?? 0)), // ? NET revenue
                        OrderCount = g.Count()
                    })
                    .OrderBy(x => x.Date)
                    .ToList(),

                "week" => payments
                    .GroupBy(p => GetWeekStart(p.CreatedAt))
                    .Select(g => new RevenueTrendResponse
                    {
                        Date = g.Key,
                        Revenue = g.Sum(p => p.Amount - (p.RefundAmount ?? 0)), // ? NET revenue
                        OrderCount = g.Count()
                    })
                    .OrderBy(x => x.Date)
                    .ToList(),

                "month" => payments
                    .GroupBy(p => new DateTime(p.CreatedAt.Year, p.CreatedAt.Month, 1))
                    .Select(g => new RevenueTrendResponse
                    {
                        Date = g.Key,
                        Revenue = g.Sum(p => p.Amount - (p.RefundAmount ?? 0)), // ? NET revenue
                        OrderCount = g.Count()
                    })
                    .OrderBy(x => x.Date)
                    .ToList(),

                _ => payments
                    .GroupBy(p => p.CreatedAt.Date)
                    .Select(g => new RevenueTrendResponse
                    {
                        Date = g.Key,
                        Revenue = g.Sum(p => p.Amount - (p.RefundAmount ?? 0)), // ? NET revenue
                        OrderCount = g.Count()
                    })
                    .OrderBy(x => x.Date)
                    .ToList()
            };

            return grouped;
        }

        public async Task<List<TopProductResponse>> GetTopProductsAsync(
            DateTime? startDate,
            DateTime? endDate,
            int limit,
            CancellationToken cancellationToken = default)
        {
            var query = _context.OrderItems
                .Include(oi => oi.Product)
                .Include(oi => oi.Order)
                .AsQueryable();

            // Apply date filters if provided
            if (startDate.HasValue)
                query = query.Where(oi => oi.Order.OrderDate >= startDate.Value);

            if (endDate.HasValue)
                query = query.Where(oi => oi.Order.OrderDate <= endDate.Value);

            var orderItems = await query.ToListAsync(cancellationToken);

            var topProducts = orderItems
                .GroupBy(oi => oi.ProductId)
                .Select(g => new TopProductResponse
                {
                    ProductId = g.Key,
                    ProductName = g.First().Product.Name,
                    OrderCount = g.Select(oi => oi.OrderId).Distinct().Count(),
                    
                    // Populate both legacy and new properties
                    QuantitySold = g.Sum(oi => oi.Quantity),
                    SoldQuantity = g.Sum(oi => oi.Quantity), // Legacy
                    
                    TotalRevenue = g.Sum(oi => oi.TotalPrice),
                    TotalIncome = g.Sum(oi => oi.TotalPrice) // Legacy
                })
                .OrderByDescending(x => x.TotalRevenue)
                .Take(limit)
                .ToList();

            return topProducts;
        }

        public async Task<List<CategoryPerformanceResponse>> GetCategoryPerformanceAsync(
            DateTime? startDate,
            DateTime? endDate,
            CancellationToken cancellationToken = default)
        {
            var query = _context.OrderItems
                .Include(oi => oi.Product)
                    .ThenInclude(p => p.Category)
                .Include(oi => oi.Order)
                .Where(oi => oi.Product.CategoryId.HasValue) // Filter out products without category
                .AsQueryable();

            if (startDate.HasValue)
                query = query.Where(oi => oi.Order.OrderDate >= startDate.Value);

            if (endDate.HasValue)
                query = query.Where(oi => oi.Order.OrderDate <= endDate.Value);

            var orderItems = await query.ToListAsync(cancellationToken);
            var totalRevenue = orderItems.Sum(oi => oi.TotalPrice);

            var categories = orderItems
                .GroupBy(oi => oi.Product.CategoryId!.Value) // Use .Value since we filtered nulls above
                .Select(g => new CategoryPerformanceResponse
                {
                    CategoryId = g.Key,
                    CategoryName = g.First().Product.Category?.Name ?? "Unknown",
                    ProductCount = g.Select(oi => oi.ProductId).Distinct().Count(),
                    OrderCount = g.Select(oi => oi.OrderId).Distinct().Count(),
                    TotalRevenue = g.Sum(oi => oi.TotalPrice),
                    Percentage = totalRevenue > 0 ? (g.Sum(oi => oi.TotalPrice) / totalRevenue) * 100 : 0
                })
                .OrderByDescending(x => x.TotalRevenue)
                .ToList();

            return categories;
        }

        // ================================
        // Revenue Analytics (Legacy + New Combined)
        // ================================

        // Legacy method - kept for backward compatibility
        // ? UPDATED: Returns NET revenue (gross - refunds)
        public async Task<decimal> GetTotalIncomeAsync(
            DateTime? from = null, 
            DateTime? to = null, 
            CancellationToken cancellationToken = default)
        {
            var query = _context.Payments
                .Where(p => p.Status == "succeeded" || p.Status == "partially_refunded" || p.Status == "refunded");
            
            if (from.HasValue) 
                query = query.Where(p => p.CreatedAt >= from.Value);
            if (to.HasValue) 
                query = query.Where(p => p.CreatedAt <= to.Value);
            
            var payments = await query.ToListAsync(cancellationToken);
            
            // ? NET Revenue = Gross Revenue - Total Refunds
            var grossRevenue = payments.Sum(p => p.Amount);
            var totalRefunds = payments.Sum(p => p.RefundAmount ?? 0);
            return grossRevenue - totalRefunds;
        }

        // Legacy method - kept for backward compatibility
        // ? UPDATED: Uses NET revenue for daily average
        public async Task<decimal> GetDailyAverageIncomeAsync(
            DateTime? from = null, 
            DateTime? to = null, 
            CancellationToken cancellationToken = default)
        {
            var query = _context.Payments
                .Where(p => p.Status == "succeeded" || p.Status == "partially_refunded" || p.Status == "refunded");
            
            if (from.HasValue) 
                query = query.Where(p => p.CreatedAt >= from.Value);
            if (to.HasValue) 
                query = query.Where(p => p.CreatedAt <= to.Value);
            
            var payments = await query.ToListAsync(cancellationToken);
            
            // ? NET Revenue calculation
            var grossRevenue = payments.Sum(p => p.Amount);
            var totalRefunds = payments.Sum(p => p.RefundAmount ?? 0);
            var netRevenue = grossRevenue - totalRefunds;
            
            // Calculate days in range
            var actualFrom = from ?? await _context.Payments.MinAsync(p => p.CreatedAt, cancellationToken);
            var actualTo = to ?? DateTime.UtcNow;
            var days = (actualTo - actualFrom).TotalDays;
            var numDays = days > 0 ? days : 1;
            
            return netRevenue / (decimal)numDays;
        }

        // Legacy method - kept for backward compatibility
        // ? UPDATED: Returns NET revenue per day
        public async Task<List<DailyIncomeResponse>> GetIncomePerDayAsync(
            DateTime? from = null, 
            DateTime? to = null, 
            CancellationToken cancellationToken = default)
        {
            var query = _context.Payments
                .Where(p => p.Status == "succeeded" || p.Status == "partially_refunded" || p.Status == "refunded");
                
            if (from.HasValue)
                query = query.Where(p => p.CreatedAt >= from.Value);
            if (to.HasValue)
                query = query.Where(p => p.CreatedAt <= to.Value);
                
            var payments = await query.ToListAsync(cancellationToken);
            
            // ? Group and calculate NET revenue per day
            return payments
                .GroupBy(p => p.CreatedAt.Date)
                .Select(g => new DailyIncomeResponse
                {
                    Date = g.Key,
                    Amount = g.Sum(p => p.Amount - (p.RefundAmount ?? 0)) // NET revenue
                })
                .OrderBy(x => x.Date)
                .ToList();
        }

        // ================================
        // Customer Analytics (includes legacy GetUserCountAsync)
        // ================================

        // Legacy method - kept for backward compatibility
        public async Task<int> GetUserCountAsync(CancellationToken cancellationToken = default)
        {
            return await _context.Users.CountAsync(cancellationToken);
        }

        public async Task<CustomerStatisticsResponse> GetCustomerStatisticsAsync(
            DateTime? startDate,
            DateTime? endDate,
            CancellationToken cancellationToken = default)
        {
            // ? FIX: Customer = someone who has placed at least 1 order with successful payment
            var ordersQuery = _context.Orders
                .Include(o => o.Payment)
                .AsQueryable();

            if (startDate.HasValue)
                ordersQuery = ordersQuery.Where(o => o.OrderDate >= startDate.Value);

            if (endDate.HasValue)
                ordersQuery = ordersQuery.Where(o => o.OrderDate <= endDate.Value);

            var ordersInPeriod = await ordersQuery.ToListAsync(cancellationToken);
            
            // Total customers = distinct users who ordered in this period
            var customerIdsInPeriod = ordersInPeriod.Select(o => o.UserId).Distinct().ToList();
            var totalCustomers = customerIdsInPeriod.Count;

            // Get order counts per customer in this period
            var orderCountsInPeriod = ordersInPeriod
                .GroupBy(o => o.UserId)
                .ToDictionary(g => g.Key, g => g.Count());

            // New customers = users with exactly 1 order in this period
            var newCustomers = customerIdsInPeriod.Count(userId =>
                orderCountsInPeriod.ContainsKey(userId) && orderCountsInPeriod[userId] == 1);
            
            // Returning customers = users with 2+ orders in this period
            var returningCustomers = customerIdsInPeriod.Count(userId =>
                orderCountsInPeriod.ContainsKey(userId) && orderCountsInPeriod[userId] > 1);

            // ? FIX: Calculate average lifetime value using NET payment revenue (Amount - RefundAmount)
            var allOrdersForCustomers = await _context.Orders
                .Include(o => o.Payment)
                .Where(o => customerIdsInPeriod.Contains(o.UserId))
                .ToListAsync(cancellationToken);
            
            // ? Use NET revenue from payments instead of Order.TotalAmount
            var totalSpent = allOrdersForCustomers
                .Where(o => o.Payment != null && 
                    (o.Payment.Status == "succeeded" || 
                     o.Payment.Status == "partially_refunded" || 
                     o.Payment.Status == "refunded"))
                .Sum(o => o.Payment.Amount - (o.Payment.RefundAmount ?? 0));
            
            var averageLifetimeValue = totalCustomers > 0 ? totalSpent / totalCustomers : 0;
            
            // Average orders per customer (for customers in this period)
            var averageOrdersPerCustomer = totalCustomers > 0 
                ? (decimal)allOrdersForCustomers.Count / totalCustomers 
                : 0;

            return new CustomerStatisticsResponse
            {
                TotalCustomers = totalCustomers,
                NewCustomers = newCustomers,
                ReturningCustomers = returningCustomers,
                AverageLifetimeValue = averageLifetimeValue,
                AverageOrdersPerCustomer = averageOrdersPerCustomer
            };
        }

        public async Task<List<TopCustomerResponse>> GetTopCustomersAsync(
            int limit,
            CancellationToken cancellationToken = default)
        {
            // ? FIX: Use Payments (NET revenue after refunds) instead of Order.TotalAmount
            var orders = await _context.Orders
                .Include(o => o.User)
                .Include(o => o.Payment)
                .Where(o => o.Payment != null)
                .ToListAsync(cancellationToken);

            var topCustomers = orders
                .GroupBy(o => o.UserId)
                .Select(g => new TopCustomerResponse
                {
                    UserId = g.Key,
                    CustomerName = $"{g.First().User.FirstName} {g.First().User.LastName}",
                    Email = g.First().User.Email ?? string.Empty,
                    // ? Count only orders with successful/refunded payments
                    TotalOrders = g.Count(o => o.Payment != null && 
                        (o.Payment.Status == "succeeded" || 
                         o.Payment.Status == "partially_refunded" || 
                         o.Payment.Status == "refunded")),
                    // ? Calculate NET revenue (Amount - RefundAmount)
                    TotalSpent = g.Where(o => o.Payment != null &&
                        (o.Payment.Status == "succeeded" || 
                         o.Payment.Status == "partially_refunded" || 
                         o.Payment.Status == "refunded"))
                        .Sum(o => o.Payment.Amount - (o.Payment.RefundAmount ?? 0)),
                    LastOrderDate = g.Max(o => o.OrderDate)
                })
                .OrderByDescending(x => x.TotalSpent)
                .Take(limit)
                .ToList();

            return topCustomers;
        }

        public async Task<ReviewStatisticsResponse> GetReviewStatisticsAsync(
            CancellationToken cancellationToken = default)
        {
            var reviews = await _context.ProductReviews.ToListAsync(cancellationToken);

            var approvedReviews = reviews.Where(r => r.IsApproved).ToList();
            var averageRating = approvedReviews.Any() 
                ? approvedReviews.Average(r => r.Rating) 
                : 0;

            var ratingDistribution = new Dictionary<int, int>();
            for (int i = 1; i <= 5; i++)
            {
                ratingDistribution[i] = reviews.Count(r => r.Rating == i);
            }

            var approvalRate = reviews.Count > 0 
                ? (double)approvedReviews.Count / reviews.Count * 100 
                : 0;

            return new ReviewStatisticsResponse
            {
                AverageRating = averageRating,
                TotalReviews = reviews.Count,
                ApprovedReviews = approvedReviews.Count,
                PendingReviews = reviews.Count(r => !r.IsApproved),
                RatingDistribution = ratingDistribution,
                ApprovalRate = approvalRate
            };
        }

        public async Task<List<EmployeePerformanceResponse>> GetEmployeePerformanceAsync(
            DateTime? startDate,
            DateTime? endDate,
            CancellationToken cancellationToken = default)
        {
            var query = _context.Orders
                .Include(o => o.AssignedEmployee)
                .Where(o => o.AssignedEmployeeId != null)
                .AsQueryable();

            if (startDate.HasValue)
                query = query.Where(o => o.OrderDate >= startDate.Value);

            if (endDate.HasValue)
                query = query.Where(o => o.OrderDate <= endDate.Value);

            var orders = await query.ToListAsync(cancellationToken);

            var performance = orders
                .GroupBy(o => o.AssignedEmployeeId!.Value)
                .Select(g => new EmployeePerformanceResponse
                {
                    EmployeeId = g.Key,
                    EmployeeName = $"{g.First().AssignedEmployee!.FirstName} {g.First().AssignedEmployee.LastName}",
                    AssignedOrders = g.Count(),
                    CompletedOrders = g.Count(o => o.Status == OrderStatus.Delivered),
                    CompletionRate = g.Count() > 0 
                        ? (double)g.Count(o => o.Status == OrderStatus.Delivered) / g.Count() * 100 
                        : 0,
                    AverageCompletionDays = g.Where(o => o.CompletedAt.HasValue)
                        .Select(o => (o.CompletedAt!.Value - o.OrderDate).TotalDays)
                        .DefaultIfEmpty(0)
                        .Average(),
                    TotalRevenue = g.Sum(o => o.TotalAmount)
                })
                .OrderByDescending(x => x.CompletionRate)
                .ToList();

            return performance;
        }

        private DateTime GetWeekStart(DateTime date)
        {
            int diff = (7 + (date.DayOfWeek - DayOfWeek.Monday)) % 7;
            return date.AddDays(-1 * diff).Date;
        }
    }
}
