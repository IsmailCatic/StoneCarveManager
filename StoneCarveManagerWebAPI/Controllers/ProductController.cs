using Microsoft.AspNetCore.Mvc;
using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.IServices;

namespace StoneCarveManagerWebAPI.Controllers
{
    public class ProductController
        : BaseCRUDController<ProductResponse, ProductSearchObject, ProductInsertRequest, ProductUpdateRequest>
    {
        private readonly IProductService _productService;
        private readonly IProductReviewService _reviewService;


        public ProductController(IProductService service, IProductReviewService reviewService) : base(service)
        {
            _productService = service;
            _reviewService = reviewService;
        }

        [HttpPatch("{id}/increment-view-count")]
        public async Task<IActionResult> IncrementViewCount(int id)
        {
            var result = await _productService.IncrementViewCountAsync(id);
            if (!result)
                return NotFound();

            return Ok();
        }

        [HttpPost("{productId}/images")]
        public async Task<IActionResult> UploadImage(int productId, [FromForm] ProductImageUploadRequest request, CancellationToken cancellationToken)
        {
            var result = await _productService.AddProductImageAsync(productId, request, cancellationToken);
            return Ok(result);
        }

        [HttpDelete("{productId}/images/{imageId}")]
        public async Task<IActionResult> DeleteProductImage(int productId, int imageId, CancellationToken cancellationToken)
        {
            await _productService.DeleteProductImageAsync(productId, imageId, cancellationToken);
            return NoContent();
        }

        [HttpGet("{productId}/reviews")]
        public async Task<IActionResult> GetProductReviews(int productId)
        {
            var list = await _reviewService.GetByProductIdAsync(productId);
            return Ok(list);
        }

        [HttpPost("{productId}/reviews")]
        public async Task<IActionResult> AddProductReview(int productId, [FromBody] ProductReviewInsertRequest request)
        {
            request.ProductId = productId;
            var review = await _reviewService.InsertAsync(request);
            return Ok(review);
        }
    }
}
