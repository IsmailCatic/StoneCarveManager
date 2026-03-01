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
    public class BlogPostController
        : BaseCRUDController<BlogPostResponse, BlogPostSearchObject, BlogPostInsertRequest, BlogPostUpdateRequest>
    {
        private readonly IBlogPostService _blogPostService;
        private readonly IValidator<BlogImageUploadRequest> _imageUploadValidator;

        public BlogPostController(
            IBlogPostService service,
            IValidator<BlogPostInsertRequest> insertValidator,
            IValidator<BlogPostUpdateRequest> updateValidator,
            IValidator<BlogImageUploadRequest> imageUploadValidator)
            : base(service, insertValidator, updateValidator)
        {
            _blogPostService = service;
            _imageUploadValidator = imageUploadValidator;
        }

        // Override Create - Admin/Employee only
        [HttpPost]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Employee}")]
        public override async Task<BlogPostResponse> Create([FromBody] BlogPostInsertRequest request)
        {
            return await base.Create(request);
        }

        // Override Update - Admin/Employee only
        [HttpPut("{id}")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Employee}")]
        public override async Task<BlogPostResponse?> Update(int id, [FromBody] BlogPostUpdateRequest request)
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

        [HttpPost("{blogPostId}/images")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Employee}")]
        public async Task<IActionResult> UploadImage(int blogPostId, [FromForm] BlogImageUploadRequest request, CancellationToken cancellationToken)
        {
            var validationResult = await _imageUploadValidator.ValidateAsync(request, cancellationToken);
            if (!validationResult.IsValid)
                return BadRequest(new { errors = validationResult.Errors.Select(e => new { field = e.PropertyName, message = e.ErrorMessage }) });

            var result = await _blogPostService.AddBlogImageAsync(blogPostId, request, cancellationToken);
            return Ok(result);
        }

        [HttpPatch("{id}/increment-view-count")]
        [AllowAnonymous]
        public async Task<IActionResult> IncrementViewCount(int id)
        {
            var result = await _blogPostService.IncrementViewCountAsync(id);
            if (!result)
                return NotFound(new { message = "Blog post not found" });

            return Ok();
        }

        [HttpPatch("{id}/publish")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Employee}")]
        public async Task<IActionResult> Publish(int id)
        {
            var result = await _blogPostService.PublishAsync(id);
            if (!result)
                return NotFound(new { message = "Blog post not found" });

            return Ok();
        }
    }
}
