using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.Responses.Analytics;
using StoneCarveManager.Services.IServices;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace StoneCarveManagerWebAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "Admin")]
    public class AnalyticsController : ControllerBase
    {
        private readonly IAnalyticsService _analyticsService;

        public AnalyticsController(IAnalyticsService analyticsService)
        { 
            _analyticsService = analyticsService;
        }

        // ================================
        // Legacy Endpoints (backward compatibility)
        // ================================

        [HttpGet("total-income")]
        public async Task<IActionResult> GetTotalIncome([FromQuery] DateTime? from, [FromQuery] DateTime? to)
        { 
            return Ok(await _analyticsService.GetTotalIncomeAsync(from, to)); 
        }

        [HttpGet("daily-income")]
        public async Task<IActionResult> GetIncomePerDay([FromQuery] DateTime? from, [FromQuery] DateTime? to)
        {
            return Ok(await _analyticsService.GetIncomePerDayAsync(from, to));
        }

        // ================================
        // NEW ENDPOINTS - Dashboard Statistics
        // ================================
        [HttpGet("dashboard")]
        public async Task<ActionResult<DashboardStatisticsResponse>> GetDashboardStatistics(
            [FromQuery] DateTime? startDate,
            [FromQuery] DateTime? endDate,
            CancellationToken cancellationToken = default)
        {
            var stats = await _analyticsService.GetDashboardStatisticsAsync(
                startDate ?? DateTime.UtcNow.AddMonths(-1),
                endDate ?? DateTime.UtcNow,
                cancellationToken
            );
            return Ok(stats);
        }

        // ================================
        // Revenue Analytics
        // ================================
        [HttpGet("revenue-by-method")]
        public async Task<ActionResult<List<RevenueByMethodResponse>>> GetRevenueByPaymentMethod(
            [FromQuery] DateTime? startDate,
            [FromQuery] DateTime? endDate,
            CancellationToken cancellationToken = default)
        {
            var data = await _analyticsService.GetRevenueByPaymentMethodAsync(
                startDate, endDate, cancellationToken
            );
            return Ok(data);
        }

        // ================================
        // Product Analytics
        // ================================
        [HttpGet("top-products")]
        public async Task<ActionResult<List<TopProductResponse>>> GetTopProducts(
            [FromQuery] DateTime? startDate,
            [FromQuery] DateTime? endDate,
            [FromQuery] int limit = 10,
            CancellationToken cancellationToken = default)
        {
            var products = await _analyticsService.GetTopProductsAsync(
                startDate, endDate, limit, cancellationToken
            );
            return Ok(products);
        }

        [HttpGet("category-performance")]
        public async Task<ActionResult<List<CategoryPerformanceResponse>>> GetCategoryPerformance(
            [FromQuery] DateTime? startDate,
            [FromQuery] DateTime? endDate,
            CancellationToken cancellationToken = default)
        {
            var data = await _analyticsService.GetCategoryPerformanceAsync(
                startDate, endDate, cancellationToken
            );
            return Ok(data);
        }

        // ================================
        // Customer Analytics
        // ================================
        [HttpGet("customer-stats")]
        public async Task<ActionResult<CustomerStatisticsResponse>> GetCustomerStatistics(
            [FromQuery] DateTime? startDate,
            [FromQuery] DateTime? endDate,
            CancellationToken cancellationToken = default)
        {
            var stats = await _analyticsService.GetCustomerStatisticsAsync(
                startDate, endDate, cancellationToken
            );
            return Ok(stats);
        }

        [HttpGet("top-customers")]
        public async Task<ActionResult<List<TopCustomerResponse>>> GetTopCustomers(
            [FromQuery] int limit = 10,
            CancellationToken cancellationToken = default)
        {
            var customers = await _analyticsService.GetTopCustomersAsync(limit, cancellationToken);
            return Ok(customers);
        }

        // ================================
        // Review Analytics
        // ================================
        [HttpGet("review-stats")]
        public async Task<ActionResult<ReviewStatisticsResponse>> GetReviewStatistics(
            CancellationToken cancellationToken = default)
        {
            var stats = await _analyticsService.GetReviewStatisticsAsync(cancellationToken);
            return Ok(stats);
        }

        // ================================
        // Employee Performance
        // ================================
        [HttpGet("employee-performance")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<List<EmployeePerformanceResponse>>> GetEmployeePerformance(
            [FromQuery] DateTime? startDate,
            [FromQuery] DateTime? endDate,
            CancellationToken cancellationToken = default)
        {
            var data = await _analyticsService.GetEmployeePerformanceAsync(
                startDate, endDate, cancellationToken
            );
            return Ok(data);
        }
    }
}
