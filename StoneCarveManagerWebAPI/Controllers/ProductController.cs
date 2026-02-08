using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.Database.Entities;
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

        // State Machine Endpoints
        [HttpPatch("{id}/activate")]
        public IActionResult Activate(int id)
        {
            var result = _productService.Activate(id);
            return Ok(result);
        }

        [HttpPatch("{id}/hide")]
        public IActionResult Hide(int id)
        {
            var result = _productService.Hide(id);
            return Ok(result);
        }

        [HttpPatch("{id}/make-service")]
        public IActionResult MakeService(int id)
        {
            var result = _productService.MakeService(id);
            return Ok(result);
        }

        [HttpPatch("{id}/add-to-portfolio")]
        public IActionResult AddToPortfolio(int id)
        {
            var result = _productService.AddToPortfolio(id);
            return Ok(result);
        }

        [HttpGet("{id}/allowed-actions")]
        public IActionResult GetAllowedActions(int id)
        {
            var actions = _productService.AllowedActions(id);
            return Ok(actions);
        }

        // Helper endpoints for filtering
        [HttpGet("services")]
        public async Task<IActionResult> GetServices([FromQuery] ProductSearchObject search)
        {
            search.ProductState = "service";
            search.IsActive = true;
            var result = await _productService.GetAsync(search);
            return Ok(result);
        }

        [HttpGet("portfolio")]
        public async Task<IActionResult> GetPortfolio([FromQuery] ProductSearchObject search)
        {
            search.ProductState = "portfolio";
            var result = await _productService.GetAsync(search);
            return Ok(result);
        }


        

    }
}
