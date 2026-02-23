using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.Responses.Analytics;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.IServices
{
    public interface IAnalyticsService
    {
        // ================================
        // Dashboard
        // ================================
        Task<DashboardStatisticsResponse> GetDashboardStatisticsAsync(
            DateTime startDate, 
            DateTime endDate, 
            CancellationToken cancellationToken = default);

        // ================================
        // Revenue Analytics
        // ================================
        Task<List<RevenueByMethodResponse>> GetRevenueByPaymentMethodAsync(
            DateTime? startDate, 
            DateTime? endDate, 
            CancellationToken cancellationToken = default);

        Task<List<RevenueTrendResponse>> GetRevenueTrendAsync(
            DateTime startDate, 
            DateTime endDate, 
            string groupBy, 
            CancellationToken cancellationToken = default);

        Task<decimal> GetTotalIncomeAsync(
            DateTime? from = null, 
            DateTime? to = null, 
            CancellationToken cancellationToken = default);

        Task<decimal> GetDailyAverageIncomeAsync(
            DateTime? from = null, 
            DateTime? to = null, 
            CancellationToken cancellationToken = default);

        Task<List<DailyIncomeResponse>> GetIncomePerDayAsync(
            DateTime? from = null, 
            DateTime? to = null, 
            CancellationToken cancellationToken = default);

        // ================================
        // Product Analytics
        // ================================
        Task<List<TopProductResponse>> GetTopProductsAsync(
            DateTime? startDate, 
            DateTime? endDate, 
            int limit, 
            CancellationToken cancellationToken = default);

        Task<List<CategoryPerformanceResponse>> GetCategoryPerformanceAsync(
            DateTime? startDate, 
            DateTime? endDate, 
            CancellationToken cancellationToken = default);

        // ================================
        // Customer Analytics
        // ================================
        Task<CustomerStatisticsResponse> GetCustomerStatisticsAsync(
            DateTime? startDate, 
            DateTime? endDate, 
            CancellationToken cancellationToken = default);

        Task<List<TopCustomerResponse>> GetTopCustomersAsync(
            int limit, 
            CancellationToken cancellationToken = default);

        Task<int> GetUserCountAsync(CancellationToken cancellationToken = default);

        // ================================
        // Review Analytics
        // ================================
        Task<ReviewStatisticsResponse> GetReviewStatisticsAsync(
            CancellationToken cancellationToken = default);

        // ================================
        // Employee Performance
        // ================================
        Task<List<EmployeePerformanceResponse>> GetEmployeePerformanceAsync(
            DateTime? startDate, 
            DateTime? endDate, 
            CancellationToken cancellationToken = default);
    }
}
