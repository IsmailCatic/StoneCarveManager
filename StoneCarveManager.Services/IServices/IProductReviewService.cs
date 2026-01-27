using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.Base;

namespace StoneCarveManager.Services.IServices
{
    public interface IProductReviewService
        : ICRUDService<ProductReviewResponse, ProductReviewSearchObject, ProductReviewInsertRequest, ProductReviewUpdateRequest>
    {
        Task<bool> ApproveReviewAsync(int reviewId);
        Task<bool> RejectReviewAsync(int reviewId);
        Task<List<ProductReviewResponse>> GetByProductIdAsync(int productId);
        Task<ProductReviewResponse?> GetByOrderIdAsync(int orderId);

        Task<ProductReviewResponse> InsertAsync(ProductReviewInsertRequest request);
        Task<PagedResult<ProductReviewResponse>> GetAsync(ProductReviewSearchObject search); // Za admin review pregled
    }
}
