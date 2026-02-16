using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.Base;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.IServices
{
    public interface ICategoryService
          : ICRUDService<CategoryResponse, CategorySearchObject, CategoryInsertRequest, CategoryUpdateRequest>
    {
        /// <summary>
        /// Upload category image
        /// Replaces existing image if present
        /// </summary>
        Task<string> UploadCategoryImageAsync(int categoryId, CategoryImageUploadRequest request, CancellationToken cancellationToken = default);
        
        /// <summary>
        /// Delete category image
        /// Sets ImageUrl to null
        /// </summary>
        Task<bool> DeleteCategoryImageAsync(int categoryId, CancellationToken cancellationToken = default);
    }
}
