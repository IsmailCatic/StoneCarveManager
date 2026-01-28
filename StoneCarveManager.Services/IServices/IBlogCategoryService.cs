using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.Base;
using System.Threading;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.IServices
{
    public interface IBlogCategoryService
        : ICRUDService<BlogCategoryResponse, BlogCategorySearchObject, BlogCategoryInsertRequest, BlogCategoryUpdateRequest>
    {
        Task<bool> ToggleActiveAsync(int id, CancellationToken cancellationToken = default);
    }
}