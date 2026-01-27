using Microsoft.AspNetCore.Mvc;
using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses.StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.IServices;

namespace StoneCarveManagerWebAPI.Controllers
{
    public class OrderController
           : BaseCRUDController<OrderResponse, OrderSearchObject, OrderInsertRequest, OrderUpdateRequest>
    {
        private readonly IOrderService _orderService;

        public OrderController(IOrderService service) : base(service)
        {
            _orderService = service;
        }


        [HttpPost("{orderId}/progress-images")]
        public async Task<IActionResult> UploadProgressImage(int orderId, [FromForm] OrderProgressImageUploadRequest request, CancellationToken cancellationToken)
        {
            var result = await _orderService.AddOrderProgressImageAsync(orderId, request, cancellationToken);
            return Ok(result);
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

    }

}
