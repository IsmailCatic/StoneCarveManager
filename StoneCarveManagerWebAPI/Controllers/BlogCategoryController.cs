using FluentValidation;
using Microsoft.AspNetCore.Mvc;
using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.IServices;

namespace StoneCarveManagerWebAPI.Controllers
{
    public class BlogCategoryController
        : BaseCRUDController<BlogCategoryResponse, BlogCategorySearchObject, BlogCategoryInsertRequest, BlogCategoryUpdateRequest>
    {
        private readonly IBlogCategoryService _service;

        public BlogCategoryController(
            IBlogCategoryService service,
            IValidator<BlogCategoryInsertRequest> insertValidator,
            IValidator<BlogCategoryUpdateRequest> updateValidator)
            : base(service, insertValidator, updateValidator)
        {
            _service = service;
        }

        [HttpGet("active")]
        public async Task<IActionResult> GetActive(CancellationToken cancellationToken)
        {
            var search = new BlogCategorySearchObject { IsActive = true, RetrieveAll = true };
            var result = await _service.GetAsync(search);
            return Ok(result.Items);
        }

        [HttpPatch("{id}/toggle-active")]
        public async Task<IActionResult> ToggleActive(int id, CancellationToken cancellationToken)
        {
            var ok = await _service.ToggleActiveAsync(id, cancellationToken);
            if (!ok)
                return NotFound(new { message = "Blog category not found" });

            return Ok();
        }
    }
}