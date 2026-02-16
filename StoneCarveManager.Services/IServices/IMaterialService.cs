using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.Base;
using System.Threading;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.IServices
{
    public interface IMaterialService
        : ICRUDService<MaterialResponse, MaterialSearchObject, MaterialInsertRequest, MaterialUpdateRequest>
    {
        /// <summary>
        /// Upload material image
        /// Replaces existing image if present
        /// </summary>
        Task<string> UploadMaterialImageAsync(int materialId, MaterialImageUploadRequest request, CancellationToken cancellationToken = default);
        
        /// <summary>
        /// Delete material image
        /// Sets ImageUrl to null
        /// </summary>
        Task<bool> DeleteMaterialImageAsync(int materialId, CancellationToken cancellationToken = default);
    }
}
