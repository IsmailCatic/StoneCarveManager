using Microsoft.AspNetCore.Mvc;
using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses.StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.IServices;
using System.Threading;
using System.Threading.Tasks;
using System;
using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;

namespace StoneCarveManagerWebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class OrderController
           : BaseCRUDController<OrderResponse, OrderSearchObject, OrderInsertRequest, OrderUpdateRequest>
    {
        private readonly IOrderService _orderService;
        private readonly IProductReviewService _reviewService;

        public OrderController(IOrderService service, IProductReviewService reviewService) : base(service)
        {
            _orderService = service;
            _reviewService = reviewService;
        }


        [HttpPost("{orderId}/progress-images")]
        public async Task<IActionResult> UploadProgressImage(int orderId, [FromForm] OrderProgressImageUploadRequest request, CancellationToken cancellationToken)
        {
            var result = await _orderService.AddOrderProgressImageAsync(orderId, request, cancellationToken);
            return Ok(result);
        }

        [HttpDelete("progress-images/{id}")]
        public async Task<IActionResult> DeleteProgressImage(int id, CancellationToken cancellationToken)
        {
            var deleted = await _orderService.DeleteOrderProgressImageAsync(id, cancellationToken);
            if (!deleted)
                return NotFound();
            return NoContent();
        }

        [HttpGet("{orderId}/review")]
        public async Task<IActionResult> GetOrderReview(int orderId)
        {
            var review = await _reviewService.GetByOrderIdAsync(orderId);
            return Ok(review);
        }

        [HttpPost("{orderId}/review")]
        public async Task<IActionResult> AddOrderReview(int orderId, [FromBody] ProductReviewInsertRequest request)
        {
            request.OrderId = orderId;
            var review = await _reviewService.InsertAsync(request);
            return Ok(review);
        }




        // Example custom endpoint: mark order as completed
        [HttpPatch("{id}/mark-completed")]
        public async Task<IActionResult> MarkCompleted(int id)
        {
            var existing = await _orderService.GetByIdAsync(id);
            if (existing == null)
                return NotFound();

            var update = new OrderUpdateRequest
            {
                Status = OrderStatus.Delivered,
                CompletedAt = DateTime.UtcNow
            };

            var result = await _orderService.UpdateAsync(id, update);
            if (result == null)
                return NotFound();

            return Ok(result);
        }

        /// <summary>
        /// Get orders filtered by date range for better performance with large datasets
        /// </summary>
        /// <param name="startDate">Start date (inclusive)</param>
        /// <param name="endDate">End date (inclusive)</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>List of orders within the specified date range</returns>
        [HttpGet("by-date-range")]
        public async Task<ActionResult<List<OrderResponse>>> GetOrdersByDateRange(
            [FromQuery] DateTime startDate,
            [FromQuery] DateTime endDate,
            CancellationToken cancellationToken = default)
        {
            var orders = await _orderService.GetOrdersByDateRangeAsync(startDate, endDate, cancellationToken);
            return Ok(orders);
        }

        /// <summary>
        /// Get monthly summary with pre-aggregated order data and revenue for a specific year
        /// </summary>
        /// <param name="year">Year to get summary for (e.g., 2024)</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Monthly breakdown with order counts, revenue, and detailed orders per month</returns>
        [HttpGet("monthly-summary")]
        public async Task<ActionResult<OrderMonthlySummaryResponse>> GetMonthlySummary(
            [FromQuery] int year,
            CancellationToken cancellationToken = default)
        {
            var summary = await _orderService.GetMonthlySummaryAsync(year, cancellationToken);
            return Ok(summary);
        }

    }

}
