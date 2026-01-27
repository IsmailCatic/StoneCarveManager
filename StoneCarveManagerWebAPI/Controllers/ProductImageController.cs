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

        public ProductImageController(IProductImageService service) : base(service)
        {
            _productImageService = service;
        }

        [HttpPatch("{id}/set-primary")]
        public async Task<IActionResult> SetPrimary(int id)
        {
            var result = await _productImageService.SetPrimaryImageAsync(id);
            if (!result)
                return NotFound();

            return Ok();
        }
    }
}
