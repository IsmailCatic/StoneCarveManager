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

        public BlogPostController(IBlogPostService service) : base(service)
        {
            _blogPostService = service;
        }

        [HttpPost("{blogPostId}/images")]
        public async Task<IActionResult> UploadImage(int blogPostId, [FromForm] BlogImageUploadRequest request, CancellationToken cancellationToken)
        {
            var result = await _blogPostService.AddBlogImageAsync(blogPostId, request, cancellationToken);
            return Ok(result);
        }

        [HttpPatch("{id}/increment-view-count")]
        public async Task<IActionResult> IncrementViewCount(int id)
        {
            var result = await _blogPostService.IncrementViewCountAsync(id);
            if (!result)
                return NotFound();

            return Ok();
        }

        [HttpPatch("{id}/publish")]
        public async Task<IActionResult> Publish(int id)
        {
            var result = await _blogPostService.PublishAsync(id);
            if (!result)
                return NotFound();

            return Ok();
        }
    }
}
