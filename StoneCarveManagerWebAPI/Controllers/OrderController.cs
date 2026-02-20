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
using Microsoft.AspNetCore.Authorization;

namespace StoneCarveManagerWebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class OrderController
           : BaseCRUDController<OrderResponse, OrderSearchObject, OrderInsertRequest, OrderUpdateRequest>
    {
        private readonly IOrderService _orderService;
        private readonly IProductReviewService _reviewService;
        private readonly ICurrentUserService _currentUserService;

        public OrderController(IOrderService service, IProductReviewService reviewService, ICurrentUserService currentUserService) : base(service)
        {
            _orderService = service;
            _reviewService = reviewService;
            _currentUserService = currentUserService;
        }

        [HttpGet("my-orders")]
        [Authorize]
        public async Task<ActionResult<PagedResult<OrderResponse>>> GetMyOrders(
            [FromQuery] OrderSearchObject? search,
            CancellationToken cancellationToken = default)
        {
            var userId = _currentUserService.GetUserId();
            
            // Create search object if null
            search ??= new OrderSearchObject();
            
            // Override UserId to ensure user can only see their own orders
            search.UserId = userId;
            
            var result = await _orderService.GetAsync(search);
            return Ok(result);
        }

        [HttpGet("my-orders/active")]
        [Authorize]
        public async Task<ActionResult<PagedResult<OrderResponse>>> GetMyActiveOrders(
            [FromQuery] OrderSearchObject? search,
            CancellationToken cancellationToken = default)
        {
            var userId = _currentUserService.GetUserId();
            
            search ??= new OrderSearchObject();
            search.UserId = userId;
            
            // Filter out completed/delivered orders
            // You can adjust this based on your OrderStatus enum values
            search.RetrieveAll = true; // Get all active orders without pagination
            
            var result = await _orderService.GetAsync(search);
            
            // Filter active orders (Requested, InProgress, etc.)
            var activeOrders = result.Items?
                .Where(o => o.Status != OrderStatus.Delivered && o.Status != OrderStatus.Cancelled)
                .ToList();
            
            return Ok(new PagedResult<OrderResponse>
            {
                Items = activeOrders,
                TotalCount = activeOrders?.Count
            });
        }

        [HttpGet("my-orders/history")]
        [Authorize]
        public async Task<ActionResult<PagedResult<OrderResponse>>> GetMyOrderHistory(
            [FromQuery] OrderSearchObject? search,
            CancellationToken cancellationToken = default)
        {
            var userId = _currentUserService.GetUserId();
            
            search ??= new OrderSearchObject();
            search.UserId = userId;
            search.RetrieveAll = true;
            
            var result = await _orderService.GetAsync(search);
            
            // Filter completed/delivered orders
            var historyOrders = result.Items?
                .Where(o => o.Status == OrderStatus.Delivered || o.Status == OrderStatus.Cancelled)
                .ToList();
            
            return Ok(new PagedResult<OrderResponse>
            {
                Items = historyOrders,
                TotalCount = historyOrders?.Count
            });
        }

        [HttpGet("my-orders/{id}")]
        [Authorize]
        public async Task<ActionResult<OrderResponse>> GetMyOrderById(int id, CancellationToken cancellationToken = default)
        {
            var userId = _currentUserService.GetUserId();
            var order = await _orderService.GetByIdAsync(id);
            
            if (order == null)
                return NotFound(new { message = "Order not found" });
            
            // Security check: ensure order belongs to current user
            if (order.UserId != userId)
                return Forbid(); // 403 Forbidden
            
            return Ok(order);
        }

        [HttpPatch("{id}/status")]
        [Authorize(Roles = "Admin,Employee")]
        public async Task<IActionResult> UpdateOrderStatus(
            int id,
            [FromBody] UpdateOrderStatusRequest request,
            CancellationToken cancellationToken = default)
        {
            var result = await _orderService.UpdateOrderStatusAsync(
                id, 
                request.NewStatus, 
                request.Comment, 
                cancellationToken);
            
            if (result == null)
                return NotFound(new { message = "Order not found" });
            
            // TODO: Send notification to customer about status change
            // await _notificationService.NotifyOrderStatusChanged(result);
            
            return Ok(result);
        }

        [HttpPost("{orderId}/progress-images")]
        [Authorize(Roles = "Admin,Employee")]
        public async Task<IActionResult> UploadProgressImage(int orderId, [FromForm] OrderProgressImageUploadRequest request, CancellationToken cancellationToken)
        {
            var result = await _orderService.AddOrderProgressImageAsync(orderId, request, cancellationToken);
            return Ok(result);
        }

        [HttpDelete("progress-images/{id}")]
        [Authorize(Roles = "Admin,Employee")]
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

        [HttpGet("by-date-range")]
        public async Task<ActionResult<List<OrderResponse>>> GetOrdersByDateRange(
            [FromQuery] DateTime startDate,
            [FromQuery] DateTime endDate,
            CancellationToken cancellationToken = default)
        {
            var orders = await _orderService.GetOrdersByDateRangeAsync(startDate, endDate, cancellationToken);
            return Ok(orders);
        }

        [HttpGet("monthly-summary")]
        public async Task<ActionResult<OrderMonthlySummaryResponse>> GetMonthlySummary(
            [FromQuery] int year,
            CancellationToken cancellationToken = default)
        {
            var summary = await _orderService.GetMonthlySummaryAsync(year, cancellationToken);
            return Ok(summary);
        }

        /// Create a custom stone carving order (no predefined product)
        /// Customer specifies work type, material, dimensions, and description
        /// Perfect for unique, one-of-a-kind projects
        /// <returns>Created order with generated order number</returns>
        [HttpPost("custom")]
        [Authorize]
        public async Task<ActionResult<OrderResponse>> CreateCustomOrder(
            [FromBody] CustomOrderInsertRequest request,
            CancellationToken cancellationToken = default)
        {
            var result = await _orderService.CreateCustomOrderAsync(request, cancellationToken);
            
            if (result == null)
                return BadRequest(new { message = "Failed to create custom order" });
            
            return CreatedAtAction(nameof(GetMyOrderById), new { id = result.Id }, result);
        }

        /// Get all custom orders (Admin/Employee only)
        /// Orders where product.productState == "custom_order"
        [HttpGet("custom-orders")]
        [Authorize(Roles = "Admin,Employee")]
        public async Task<ActionResult<PagedResult<OrderResponse>>> GetCustomOrders(
            [FromQuery] OrderSearchObject? search,
            CancellationToken cancellationToken = default)
        {
            search ??= new OrderSearchObject();
            
            var result = await _orderService.GetAsync(search);
            
            // Filter only custom orders
            var customOrders = result.Items?
                .Where(o => o.OrderItems.Any(oi => oi.ProductState == "custom_order"))
                .ToList();
            
            return Ok(new PagedResult<OrderResponse>
            {
                Items = customOrders,
                TotalCount = customOrders?.Count
            });
        }

        /// Upload a reference sketch/image for a custom order
        /// Returns the URL of the uploaded image to be included in CustomOrderInsertRequest
        /// <returns>URL of the uploaded sketch</returns>
        [HttpPost("custom/upload-sketch")]
        [Authorize]
        public async Task<IActionResult> UploadCustomOrderSketch(
            [FromForm] CustomOrderSketchUploadRequest request,
            CancellationToken cancellationToken = default)
        {
            var imageUrl = await _orderService.UploadCustomOrderSketchAsync(request, cancellationToken);
            
            return Ok(new { url = imageUrl });
        }


        [HttpDelete("custom/delete-sketch")]
        [Authorize]
        public async Task<IActionResult> DeleteCustomOrderSketch(
            [FromQuery] string url,
            CancellationToken cancellationToken = default)
        {
            var deleted = await _orderService.DeleteCustomOrderSketchAsync(url, cancellationToken);
            
            if (!deleted)
                return NotFound(new { message = "Sketch not found" });
            
            return NoContent();
        }
    }

}
