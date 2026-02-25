using FluentValidation;
using Microsoft.AspNetCore.Mvc;
using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.IServices;

namespace StoneCarveManagerWebAPI.Controllers
{
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

        [HttpPost("{blogPostId}/images")]
        public async Task<IActionResult> UploadImage(int blogPostId, [FromForm] BlogImageUploadRequest request, CancellationToken cancellationToken)
        {
            var validationResult = await _imageUploadValidator.ValidateAsync(request, cancellationToken);
            if (!validationResult.IsValid)
                return BadRequest(new { errors = validationResult.Errors.Select(e => new { field = e.PropertyName, message = e.ErrorMessage }) });

            var result = await _blogPostService.AddBlogImageAsync(blogPostId, request, cancellationToken);
            return Ok(result);
        }

        [HttpPatch("{id}/increment-view-count")]
        public async Task<IActionResult> IncrementViewCount(int id)
        {
            var result = await _blogPostService.IncrementViewCountAsync(id);
            if (!result)
                return NotFound(new { message = "Blog post not found" });

            return Ok();
        }

        [HttpPatch("{id}/publish")]
        public async Task<IActionResult> Publish(int id)
        {
            var result = await _blogPostService.PublishAsync(id);
            if (!result)
                return NotFound(new { message = "Blog post not found" });

            return Ok();
        }
    }
}
