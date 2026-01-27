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

        public ProductReviewController(IProductReviewService service) : base(service)
        {
            _productReviewService = service;
        }

        [HttpGet("/api/product/{productId}/reviews")]
        public async Task<IActionResult> GetProductReviews(int productId)
        {
            var reviews = await _productReviewService.GetByProductIdAsync(productId);
            return Ok(reviews);
        }

        // Novi review za proizvod (User je iz autorizacije, OrderId je opcionalan)
        //[HttpPost("/api/product/{productId}/reviews")]
        //public async Task<IActionResult> AddProductReview(int productId, ProductReviewInsertRequest request)
        //{
        //    request.ProductId = productId;
        //    var review = await _productReviewService.InsertAsync(request);
        //    return Ok(review);
        //}

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
