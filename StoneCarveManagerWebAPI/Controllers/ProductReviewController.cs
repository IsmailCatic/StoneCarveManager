using FluentValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.IServices;
using static StoneCarveManager.Services.Constants;

namespace StoneCarveManagerWebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ProductReviewController : ControllerBase
    {
        private readonly IProductReviewService _reviewService;
        private readonly ICurrentUserService _currentUserService;
        private readonly IValidator<ProductReviewInsertRequest> _insertValidator;
        private readonly IValidator<ProductReviewUpdateRequest> _updateValidator;

        public ProductReviewController(
            IProductReviewService reviewService, 
            ICurrentUserService currentUserService,
            IValidator<ProductReviewInsertRequest> insertValidator,
            IValidator<ProductReviewUpdateRequest> updateValidator)
        {
            _reviewService = reviewService;
            _currentUserService = currentUserService;
            _insertValidator = insertValidator;
            _updateValidator = updateValidator;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<ProductReviewResponse>>> GetAll([FromQuery] ProductReviewSearchObject search)
        {
            var reviews = await _reviewService.GetAsync(search);
            return Ok(reviews);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<ProductReviewResponse>> GetById(int id)
        {
            var review = await _reviewService.GetByIdAsync(id);
            if (review == null)
                return NotFound(new { message = "Review not found" });

            return Ok(review);
        }

        [HttpGet("product/{productId}")]
        [AllowAnonymous]
        public async Task<ActionResult<List<ProductReviewResponse>>> GetByProductId(int productId)
        {
            var reviews = await _reviewService.GetByProductIdAsync(productId);
            return Ok(reviews);
        }

        [HttpGet("order/{orderId}")]
        public async Task<ActionResult<ProductReviewResponse>> GetByOrderId(int orderId)
        {
            var review = await _reviewService.GetByOrderIdAsync(orderId);
            if (review == null)
                return NotFound(new { message = "Review not found for this order" });

            return Ok(review);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] ProductReviewInsertRequest request, CancellationToken cancellationToken)
        {
            request.UserId = _currentUserService.GetUserId();

            var validationResult = await _insertValidator.ValidateAsync(request, cancellationToken);
            if (!validationResult.IsValid)
                return BadRequest(new { errors = validationResult.Errors.Select(e => new { field = e.PropertyName, message = e.ErrorMessage }) });

            var review = await _reviewService.InsertAsync(request);
            return Ok(review);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] ProductReviewUpdateRequest request, CancellationToken cancellationToken)
        {
            var validationResult = await _updateValidator.ValidateAsync(request, cancellationToken);
            if (!validationResult.IsValid)
                return BadRequest(new { errors = validationResult.Errors.Select(e => new { field = e.PropertyName, message = e.ErrorMessage }) });

            var review = await _reviewService.UpdateAsync(id, request);
            return Ok(review);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var result = await _reviewService.DeleteAsync(id);
            if (!result)
                return NotFound(new { message = "Review not found" });

            return NoContent();
        }

        [HttpPatch("{id}/approve")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Employee}")]
        public async Task<IActionResult> Approve(int id)
        {
            var result = await _reviewService.ApproveReviewAsync(id);
            if (!result)
                return NotFound(new { message = "Review not found" });

            return Ok(new { message = "Review approved successfully" });
        }

        [HttpPatch("{id}/reject")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Employee}")]
        public async Task<IActionResult> Reject(int id)
        {
            var result = await _reviewService.RejectReviewAsync(id);
            if (!result)
                return NotFound(new { message = "Review not found" });

            return Ok(new { message = "Review rejected successfully" });
        }

        [HttpGet("pending")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Employee}")]
        public async Task<ActionResult<PagedResult<ProductReviewResponse>>> GetPending()
        {
            var search = new ProductReviewSearchObject { IsApproved = false };
            var reviews = await _reviewService.GetAsync(search);
            return Ok(reviews);
        }
    }
}
