using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.Base;

namespace StoneCarveManager.Services.IServices
{
    public interface IProductService
        : ICRUDService<ProductResponse, ProductSearchObject, ProductInsertRequest, ProductUpdateRequest>
    {
        Task<ProductImageResponse> AddProductImageAsync(int productId, ProductImageUploadRequest request, CancellationToken cancellationToken = default);

        Task DeleteProductImageAsync(int productId, int imageId, CancellationToken cancellationToken = default);

        // State machine methods
        Task<ProductResponse> Activate(int id);
        Task<ProductResponse> Hide(int id);
        Task<ProductResponse> MakeService(int id);
        Task<ProductResponse> AddToPortfolio(int id);
        Task<List<string>> AllowedActions(int id);
    }
}
