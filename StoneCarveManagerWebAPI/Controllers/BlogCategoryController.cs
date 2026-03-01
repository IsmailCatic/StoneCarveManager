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

        // Override Create - Admin/Employee only
        [HttpPost]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Employee}")]
        public override async Task<BlogCategoryResponse> Create([FromBody] BlogCategoryInsertRequest request)
        {
            return await base.Create(request);
        }

        // Override Update - Admin/Employee only
        [HttpPut("{id}")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Employee}")]
        public override async Task<BlogCategoryResponse?> Update(int id, [FromBody] BlogCategoryUpdateRequest request)
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

        [HttpGet("active")]
        [AllowAnonymous]
        public async Task<IActionResult> GetActive(CancellationToken cancellationToken)
        {
            var search = new BlogCategorySearchObject { IsActive = true, RetrieveAll = true };
            var result = await _service.GetAsync(search);
            return Ok(result.Items);
        }

        [HttpPatch("{id}/toggle-active")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Employee}")]
        public async Task<IActionResult> ToggleActive(int id, CancellationToken cancellationToken)
        {
            var ok = await _service.ToggleActiveAsync(id, cancellationToken);
            if (!ok)
                return NotFound(new { message = "Blog category not found" });

            return Ok();
        }
    }
}