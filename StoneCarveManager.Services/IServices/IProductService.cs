using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.Base;

namespace StoneCarveManager.Services.IServices
{
    public interface IProductService
        : ICRUDService<ProductResponse, ProductSearchObject, ProductInsertRequest, ProductUpdateRequest>
    {
        Task<bool> IncrementViewCountAsync(int productId);

        Task<ProductImageResponse> AddProductImageAsync(int productId, ProductImageUploadRequest request, CancellationToken cancellationToken = default);

        Task DeleteProductImageAsync(int productId, int imageId, CancellationToken cancellationToken = default);
    }
}
