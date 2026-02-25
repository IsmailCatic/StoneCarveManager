using FluentValidation;
using Microsoft.AspNetCore.Mvc;
using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.IServices;

namespace StoneCarveManagerWebAPI.Controllers
{
    public class ProductImageController
        : BaseCRUDController<ProductImageResponse, ProductImageSearchObject, ProductImageInsertRequest, ProductImageUpdateRequest>
    {
        private readonly IProductImageService _productImageService;

        public ProductImageController(
            IProductImageService service,
            IValidator<ProductImageInsertRequest> insertValidator,
            IValidator<ProductImageUpdateRequest> updateValidator)
            : base(service, insertValidator, updateValidator)
        {
            _productImageService = service;
        }

        [HttpPatch("{id}/set-primary")]
        public async Task<IActionResult> SetPrimary(int id)
        {
            var result = await _productImageService.SetPrimaryImageAsync(id);
            if (!result)
                return NotFound(new { message = "Image not found" });

            return Ok(new { message = "Primary image updated successfully" });
        }
    }
}
