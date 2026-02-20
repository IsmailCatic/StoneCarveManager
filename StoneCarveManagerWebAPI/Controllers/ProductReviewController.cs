using Microsoft.AspNetCore.Mvc;
using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.IServices;

namespace StoneCarveManagerWebAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ProductReviewController
        : BaseCRUDController<ProductReviewResponse, ProductReviewSearchObject, ProductReviewInsertRequest, ProductReviewUpdateRequest>
    {
        private readonly IProductReviewService _productReviewService;

        public ProductReviewController(IProductReviewService service) : base(service)
        {
            _productReviewService = service;
        }

        // ? Admin endpoints za approve/reject reviews
        [HttpPatch("{id}/approve")]
        public async Task<IActionResult> Approve(int id)
        {
            var result = await _productReviewService.ApproveReviewAsync(id);
            if (!result)
                return NotFound();

            return Ok(new { message = "Review approved successfully" });
        }

        [HttpPatch("{id}/reject")]
        public async Task<IActionResult> Reject(int id)
        {
            var result = await _productReviewService.RejectReviewAsync(id);
            if (!result)
                return NotFound();

            return Ok(new { message = "Review rejected successfully" });
        }
    }
}
