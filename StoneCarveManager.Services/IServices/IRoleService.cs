using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.Base;

namespace StoneCarveManager.Services.IServices
{
    public interface IRoleService
        : ICRUDService<RoleResponse, RoleSearchObject, RoleInsertRequest, RoleUpdateRequest>
    {
        // Add role-specific methods here if needed
    }
}