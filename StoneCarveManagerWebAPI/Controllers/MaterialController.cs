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
    public class MaterialController
        : BaseCRUDController<MaterialResponse, MaterialSearchObject, MaterialInsertRequest, MaterialUpdateRequest>
    {
        private readonly IMaterialService _materialService;
        private readonly IValidator<MaterialImageUploadRequest> _imageUploadValidator;

        public MaterialController(
            IMaterialService service,
            IValidator<MaterialInsertRequest> insertValidator,
            IValidator<MaterialUpdateRequest> updateValidator,
            IValidator<MaterialImageUploadRequest> imageUploadValidator) 
            : base(service, insertValidator, updateValidator)
        {
            _materialService = service;
            _imageUploadValidator = imageUploadValidator;
        }

        // Override Create - Admin/Employee only
        [HttpPost]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Employee}")]
        public override async Task<MaterialResponse> Create([FromBody] MaterialInsertRequest request)
        {
            return await base.Create(request);
        }

        // Override Update - Admin/Employee only
        [HttpPut("{id}")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Employee}")]
        public override async Task<MaterialResponse?> Update(int id, [FromBody] MaterialUpdateRequest request)
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

        /// <summary>
        /// Upload material image
        /// Replaces existing image if present
        /// </summary>
        /// <param name="id">Material ID</param>
        /// <param name="request">Image upload request</param>
        /// <param name="cancellationToken"></param>
        /// <returns>URL of uploaded image</returns>
        [HttpPost("{id}/image")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Employee}")]
        public async Task<IActionResult> UploadImage(
            int id,
            [FromForm] MaterialImageUploadRequest request,
            CancellationToken cancellationToken = default)
        {
            var validationResult = await _imageUploadValidator.ValidateAsync(request, cancellationToken);
            if (!validationResult.IsValid)
                return BadRequest(new { errors = validationResult.Errors.Select(e => new { field = e.PropertyName, message = e.ErrorMessage }) });

            try
            {
                var imageUrl = await _materialService.UploadMaterialImageAsync(id, request, cancellationToken);
                return Ok(new { imageUrl });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Delete material image
        /// Sets ImageUrl to null
        /// </summary>
        /// <param name="id">Material ID</param>
        /// <param name="cancellationToken"></param>
        [HttpDelete("{id}/image")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Employee}")]
        public async Task<IActionResult> DeleteImage(
            int id,
            CancellationToken cancellationToken = default)
        {
            var deleted = await _materialService.DeleteMaterialImageAsync(id, cancellationToken);
            
            if (!deleted)
                return NotFound(new { message = "Material not found or no image to delete" });
            
            return NoContent();
        }
    }
}
