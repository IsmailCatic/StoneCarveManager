using Microsoft.AspNetCore.Mvc;
using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.IServices;

namespace StoneCarveManagerWebAPI.Controllers
{
    public class ProductReviewController
        : BaseCRUDController<ProductReviewResponse, ProductReviewSearchObject, ProductReviewInsertRequest, ProductReviewUpdateRequest>
    {
        private readonly IProductReviewService _productReviewService;
        private readonly ICurrentUserService _currentUserService;

        public ProductReviewController(IProductReviewService service, ICurrentUserService currentUserService) : base(service)
        {
            _productReviewService = service;
            _currentUserService = currentUserService;
        }

        [HttpGet("/api/product/{productId}/reviews")]
        public async Task<IActionResult> GetProductReviews(int productId)
        {
            var reviews = await _productReviewService.GetByProductIdAsync(productId);
            return Ok(reviews);
        }

        /// <summary>
        /// Add review for a product
        /// UserId is automatically extracted from JWT token
        /// </summary>
        [HttpPost("/api/product/{productId}/reviews")]
        public async Task<IActionResult> AddProductReview(int productId, [FromBody] ProductReviewInsertRequest request)
        {
            // Automatically set userId from JWT token
            request.UserId = _currentUserService.GetUserId();
            
            // Set productId from URL
            request.ProductId = productId;
            
            var review = await _productReviewService.InsertAsync(request);
            return Ok(review);
        }

        [HttpPatch("{id}/approve")]
        public async Task<IActionResult> Approve(int id)
        {
            var result = await _productReviewService.ApproveReviewAsync(id);
            if (!result)
                return NotFound();

            return Ok();
        }

        [HttpPatch("{id}/reject")]
        public async Task<IActionResult> Reject(int id)
        {
            var result = await _productReviewService.RejectReviewAsync(id);
            if (!result)
                return NotFound();

            return Ok();
        }
    }
}
