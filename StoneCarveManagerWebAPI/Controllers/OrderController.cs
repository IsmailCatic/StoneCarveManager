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

    }

}
