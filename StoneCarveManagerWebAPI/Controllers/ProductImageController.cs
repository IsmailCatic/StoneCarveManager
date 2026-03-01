using FluentValidation;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.IServices;
using static StoneCarveManager.Services.Constants;

namespace StoneCarveManagerWebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
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

        // Override Create - Admin/Employee only
        [HttpPost]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Employee}")]
        public override async Task<ProductImageResponse> Create([FromBody] ProductImageInsertRequest request)
        {
            return await base.Create(request);
        }

        // Override Update - Admin/Employee only
        [HttpPut("{id}")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Employee}")]
        public override async Task<ProductImageResponse?> Update(int id, [FromBody] ProductImageUpdateRequest request)
        {
            return await base.Update(id, request);
        }

        // Override Delete - Admin/Employee only
        [HttpDelete("{id}")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Employee}")]
        public override async Task<bool> Delete(int id)
        {
            return await base.Delete(id);
        }

        [HttpPatch("{id}/set-primary")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Employee}")]
        public async Task<IActionResult> SetPrimary(int id)
        {
            var result = await _productImageService.SetPrimaryImageAsync(id);
            if (!result)
                return NotFound(new { message = "Image not found" });

            return Ok(new { message = "Primary image updated successfully" });
        }
    }
}
