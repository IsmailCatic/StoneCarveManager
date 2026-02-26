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
            // Current period payments (only succeeded payments)
            var currentPayments = await _context.Payments
                .Include(p => p.Order)
                .Where(p => p.Status == "succeeded" && p.CreatedAt >= startDate && p.CreatedAt <= endDate)
                .ToListAsync(cancellationToken);

            // Previous period payments (only succeeded payments)
            var previousPayments = await _context.Payments
                .Include(p => p.Order)
                .Where(p => p.Status == "succeeded" && p.CreatedAt >= previousStartDate && p.CreatedAt < previousEndDate)
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

            // ? Revenue calculations from PAYMENTS (not Orders)
            var currentRevenue = currentPayments.Sum(p => p.Amount);
            var previousRevenue = previousPayments.Sum(p => p.Amount);
            var revenueChange = previousRevenue > 0 
                ? ((currentRevenue - previousRevenue) / previousRevenue) * 100 
                : 0;

            // ? Average order value from PAID orders only
            var paidOrdersCount = currentPayments.Select(p => p.OrderId).Distinct().Count();
            var averageOrderValue = paidOrdersCount > 0 ? currentRevenue / paidOrdersCount : 0;

            // Orders change
            var ordersChange = previousOrders.Count > 0
                ? ((currentOrders.Count - previousOrders.Count) * 100 / previousOrders.Count)
                : 0;

            // Customer statistics
            var allCustomers = await _context.Users
                .Where(u => u.UserRoles.Any(ur => ur.Role.Name == "User"))
                .ToListAsync(cancellationToken);

            var newCustomers = allCustomers
                .Count(u => u.CreatedAt >= startDate && u.CreatedAt <= endDate);

            var customerIdsInPeriod = currentOrders.Select(o => o.UserId).Distinct().ToList();
            var returningCustomers = customerIdsInPeriod.Count(userId =>
                _context.Orders.Any(o => o.UserId == userId && o.OrderDate < startDate));

            // Product statistics
            var totalProducts = await _context.Products.CountAsync(cancellationToken);
            var lowStockProducts = await _context.Products
                .Where(p => p.IsActive && p.StockQuantity > 0 && p.StockQuantity < 5)
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

            var successfulPayments = payments.Count(p => p.Status == "succeeded");
            var failedPayments = payments.Count(p => p.Status == "failed");
            var refundedAmount = payments
                .Where(p => p.Status == "refunded")
                .Sum(p => p.Amount);

            // Order status counts
            var customOrders = currentOrders.Count(o =>
                o.OrderItems.Any(oi => oi.Product.ProductState == "custom_order"));

            return new DashboardStatisticsResponse
            {
                // Revenue (from PAYMENTS, not Orders)
                TotalRevenue = currentRevenue,
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

                // Customers
                TotalCustomers = allCustomers.Count,
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
                .Where(p => p.Status == "succeeded");

            if (startDate.HasValue)
                query = query.Where(p => p.CreatedAt >= startDate.Value);

            if (endDate.HasValue)
                query = query.Where(p => p.CreatedAt <= endDate.Value);

            var payments = await query.ToListAsync(cancellationToken);
            var totalRevenue = payments.Sum(p => p.Amount);

            var grouped = payments
                .GroupBy(p => p.Method)
                .Select(g => new RevenueByMethodResponse
                {
                    PaymentMethod = g.Key,
                    TotalRevenue = g.Sum(p => p.Amount),
                    OrderCount = g.Count(),
                    Percentage = totalRevenue > 0 ? (g.Sum(p => p.Amount) / totalRevenue) * 100 : 0
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
                .Where(p => p.Status == "succeeded" && p.CreatedAt >= startDate && p.CreatedAt <= endDate)
                .ToListAsync(cancellationToken);

            var grouped = groupBy.ToLower() switch
            {
                "day" => payments
                    .GroupBy(p => p.CreatedAt.Date)
                    .Select(g => new RevenueTrendResponse
                    {
                        Date = g.Key,
                        Revenue = g.Sum(p => p.Amount),
                        OrderCount = g.Count()
                    })
                    .OrderBy(x => x.Date)
                    .ToList(),

                "week" => payments
                    .GroupBy(p => GetWeekStart(p.CreatedAt))
                    .Select(g => new RevenueTrendResponse
                    {
                        Date = g.Key,
                        Revenue = g.Sum(p => p.Amount),
                        OrderCount = g.Count()
                    })
                    .OrderBy(x => x.Date)
                    .ToList(),

                "month" => payments
                    .GroupBy(p => new DateTime(p.CreatedAt.Year, p.CreatedAt.Month, 1))
                    .Select(g => new RevenueTrendResponse
                    {
                        Date = g.Key,
                        Revenue = g.Sum(p => p.Amount),
                        OrderCount = g.Count()
                    })
                    .OrderBy(x => x.Date)
                    .ToList(),

                _ => payments
                    .GroupBy(p => p.CreatedAt.Date)
                    .Select(g => new RevenueTrendResponse
                    {
                        Date = g.Key,
                        Revenue = g.Sum(p => p.Amount),
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
        // ? UPDATED: Now uses Payments table for consistency
        public async Task<decimal> GetTotalIncomeAsync(
            DateTime? from = null, 
            DateTime? to = null, 
            CancellationToken cancellationToken = default)
        {
            var query = _context.Payments
                .Where(p => p.Status == "succeeded");
            
            if (from.HasValue) 
                query = query.Where(p => p.CreatedAt >= from.Value);
            if (to.HasValue) 
                query = query.Where(p => p.CreatedAt <= to.Value);
            
            return await query.SumAsync(p => p.Amount, cancellationToken);
        }

        // Legacy method - kept for backward compatibility
        // ? UPDATED: Now uses Payments table for consistency
        public async Task<decimal> GetDailyAverageIncomeAsync(
            DateTime? from = null, 
            DateTime? to = null, 
            CancellationToken cancellationToken = default)
        {
            var query = _context.Payments
                .Where(p => p.Status == "succeeded");
            
            if (from.HasValue) 
                query = query.Where(p => p.CreatedAt >= from.Value);
            if (to.HasValue) 
                query = query.Where(p => p.CreatedAt <= to.Value);
            
            var total = await query.SumAsync(p => p.Amount, cancellationToken);
            
            // Calculate days in range
            var actualFrom = from ?? await _context.Payments.MinAsync(p => p.CreatedAt, cancellationToken);
            var actualTo = to ?? DateTime.UtcNow;
            var days = (actualTo - actualFrom).TotalDays;
            var numDays = days > 0 ? days : 1;
            
            return total / (decimal)numDays;
        }

        // Legacy method - kept for backward compatibility
        // ? UPDATED: Now uses Payments table for consistency
        public async Task<List<DailyIncomeResponse>> GetIncomePerDayAsync(
            DateTime? from = null, 
            DateTime? to = null, 
            CancellationToken cancellationToken = default)
        {
            var query = _context.Payments
                .Where(p => p.Status == "succeeded");
                
            if (from.HasValue)
                query = query.Where(p => p.CreatedAt >= from.Value);
            if (to.HasValue)
                query = query.Where(p => p.CreatedAt <= to.Value);
                
            return await query
                .GroupBy(p => p.CreatedAt.Date)
                .Select(g => new DailyIncomeResponse
                {
                    Date = g.Key,
                    Amount = g.Sum(p => p.Amount)
                })
                .OrderBy(g => g.Date)
                .ToListAsync(cancellationToken);
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
            var customers = await _context.Users
                .Where(u => u.UserRoles.Any(ur => ur.Role.Name == "User"))
                .ToListAsync(cancellationToken);

            var ordersQuery = _context.Orders.AsQueryable();

            if (startDate.HasValue)
                ordersQuery = ordersQuery.Where(o => o.OrderDate >= startDate.Value);

            if (endDate.HasValue)
                ordersQuery = ordersQuery.Where(o => o.OrderDate <= endDate.Value);

            var orders = await ordersQuery.ToListAsync(cancellationToken);

            var newCustomers = startDate.HasValue && endDate.HasValue
                ? customers.Count(u => u.CreatedAt >= startDate.Value && u.CreatedAt <= endDate.Value)
                : 0;

            var customerIds = orders.Select(o => o.UserId).Distinct().ToList();
            var returningCustomers = customerIds.Count(userId =>
                _context.Orders.Count(o => o.UserId == userId) > 1);

            var totalSpent = orders.Sum(o => o.TotalAmount);
            var averageLifetimeValue = customers.Count > 0 ? totalSpent / customers.Count : 0;
            var averageOrdersPerCustomer = customers.Count > 0 
                ? (decimal)orders.Count / customers.Count 
                : 0;

            return new CustomerStatisticsResponse
            {
                TotalCustomers = customers.Count,
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
            var orders = await _context.Orders
                .Include(o => o.User)
                .ToListAsync(cancellationToken);

            var topCustomers = orders
                .GroupBy(o => o.UserId)
                .Select(g => new TopCustomerResponse
                {
                    UserId = g.Key,
                    CustomerName = $"{g.First().User.FirstName} {g.First().User.LastName}",
                    Email = g.First().User.Email ?? string.Empty,
                    TotalOrders = g.Count(),
                    TotalSpent = g.Sum(o => o.TotalAmount),
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
