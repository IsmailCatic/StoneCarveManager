using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.Base;

namespace StoneCarveManager.Services.IServices
{
    public interface IBlogPostService
        : ICRUDService<BlogPostResponse, BlogPostSearchObject, BlogPostInsertRequest, BlogPostUpdateRequest>
    {
        Task<bool> IncrementViewCountAsync(int blogPostId);
        Task<bool> PublishAsync(int blogPostId);
        Task<BlogImageResponse> AddBlogImageAsync(int blogPostId, BlogImageUploadRequest request, CancellationToken cancellationToken);
    }
}
