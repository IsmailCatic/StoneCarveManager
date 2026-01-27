using Microsoft.AspNetCore.Mvc;
using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.IServices;
using StoneCarveManager.Services.Services;

namespace StoneCarveManagerWebAPI.Controllers
{
    public class CategoryController
        : BaseCRUDController<CategoryResponse, CategorySearchObject, CategoryInsertRequest, CategoryUpdateRequest>
    {
        private readonly ICategoryService _categoryService;

        public CategoryController(ICategoryService service) : base(service)
        {
            _categoryService = service;
        }

        // ✅ Custom endpoint (ako ti treba)
        [HttpPatch("{id}/toggle-active")]
        public async Task<IActionResult> ToggleActive(int id)
        {
            var category = await _categoryService.GetByIdAsync(id);
            if (category == null)
                return NotFound();

            // Custom logic... 
            return Ok();
        }
    }
}
