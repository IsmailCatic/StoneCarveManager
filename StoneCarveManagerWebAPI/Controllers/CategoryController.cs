using FluentValidation;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.IServices;
using StoneCarveManager.Services.Services;
using System.Threading;
using System.Threading.Tasks;

namespace StoneCarveManagerWebAPI.Controllers
{
    public class CategoryController
        : BaseCRUDController<CategoryResponse, CategorySearchObject, CategoryInsertRequest, CategoryUpdateRequest>
    {
        private readonly ICategoryService _categoryService;
        private readonly IValidator<CategoryImageUploadRequest> _imageUploadValidator;

        public CategoryController(
            ICategoryService service,
            IValidator<CategoryInsertRequest> insertValidator,
            IValidator<CategoryUpdateRequest> updateValidator,
            IValidator<CategoryImageUploadRequest> imageUploadValidator) 
            : base(service, insertValidator, updateValidator)
        {
            _categoryService = service;
            _imageUploadValidator = imageUploadValidator;
        }

        // ✅ Custom endpoint (ako ti treba)
        [HttpPatch("{id}/toggle-active")]
        public async Task<IActionResult> ToggleActive(int id)
        {
            var category = await _categoryService.GetByIdAsync(id);
            if (category == null)
                return NotFound(new { message = "Category not found" });

            // Custom logic... 
            return Ok();
        }

        /// <summary>
        /// Upload category image
        /// Replaces existing image if present
        /// </summary>
        /// <param name="id">Category ID</param>
        /// <param name="request">Image upload request</param>
        /// <param name="cancellationToken"></param>
        /// <returns>URL of uploaded image</returns>
        [HttpPost("{id}/image")]
        [Authorize(Roles = "Admin,Employee")]
        public async Task<IActionResult> UploadImage(
            int id,
            [FromForm] CategoryImageUploadRequest request,
            CancellationToken cancellationToken = default)
        {
            var validationResult = await _imageUploadValidator.ValidateAsync(request, cancellationToken);
            if (!validationResult.IsValid)
                return BadRequest(new { errors = validationResult.Errors.Select(e => new { field = e.PropertyName, message = e.ErrorMessage }) });

            try
            {
                var imageUrl = await _categoryService.UploadCategoryImageAsync(id, request, cancellationToken);
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
        /// Delete category image
        /// Sets ImageUrl to null
        /// </summary>
        /// <param name="id">Category ID</param>
        /// <param name="cancellationToken"></param>
        [HttpDelete("{id}/image")]
        [Authorize(Roles = "Admin,Employee")]
        public async Task<IActionResult> DeleteImage(
            int id,
            CancellationToken cancellationToken = default)
        {
            var deleted = await _categoryService.DeleteCategoryImageAsync(id, cancellationToken);
            
            if (!deleted)
                return NotFound(new { message = "Category not found or no image to delete" });
            
            return NoContent();
        }
    }
}
