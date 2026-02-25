using FluentValidation;
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
        private readonly ICurrentUserService _currentUserService;
        private readonly IValidator<ProductImageUploadRequest> _imageUploadValidator;
        private readonly IValidator<ProductReviewInsertRequest> _reviewValidator;

        public ProductController(
            IProductService service, 
            IProductReviewService reviewService,
            ICurrentUserService currentUserService,
            IValidator<ProductInsertRequest> insertValidator,
            IValidator<ProductUpdateRequest> updateValidator,
            IValidator<ProductImageUploadRequest> imageUploadValidator,
            IValidator<ProductReviewInsertRequest> reviewValidator) 
            : base(service, insertValidator, updateValidator)
        {
            _productService = service;
            _reviewService = reviewService;
            _currentUserService = currentUserService;
            _imageUploadValidator = imageUploadValidator;
            _reviewValidator = reviewValidator;
        }

        // Override Create to add validation
        public override async Task<ProductResponse> Create([FromBody] ProductInsertRequest request)
        {
            return await base.Create(request);
        }

        // Override Update to add validation
        public override async Task<ProductResponse?> Update(int id, [FromBody] ProductUpdateRequest request)
        {
            return await base.Update(id, request);
        }

        [HttpPatch("{id}/increment-view-count")]
        public async Task<IActionResult> IncrementViewCount(int id)
        {
            var result = await _productService.IncrementViewCountAsync(id);
            if (!result)
                return NotFound(new { message = "Product not found" });

            return Ok();
        }

        [HttpPost("{productId}/images")]
        public async Task<IActionResult> UploadImage(int productId, [FromForm] ProductImageUploadRequest request, CancellationToken cancellationToken)
        {
            var validationResult = await _imageUploadValidator.ValidateAsync(request, cancellationToken);
            if (!validationResult.IsValid)
                return BadRequest(new { errors = validationResult.Errors.Select(e => new { field = e.PropertyName, message = e.ErrorMessage }) });

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
        public async Task<IActionResult> AddProductReview(int productId, [FromBody] ProductReviewInsertRequest request, CancellationToken cancellationToken)
        {
            // Automatically set userId from JWT token
            request.UserId = _currentUserService.GetUserId();
            
            // Set productId from URL
            request.ProductId = productId;

            var validationResult = await _reviewValidator.ValidateAsync(request, cancellationToken);
            if (!validationResult.IsValid)
                return BadRequest(new { errors = validationResult.Errors.Select(e => new { field = e.PropertyName, message = e.ErrorMessage }) });
            
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
