using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.Base;

namespace StoneCarveManager.Services.IServices
{
    public interface IProductImageService
        : ICRUDService<ProductImageResponse, ProductImageSearchObject, ProductImageInsertRequest, ProductImageUpdateRequest>
    {
        Task<bool> SetPrimaryImageAsync(int productImageId);
    }
}
