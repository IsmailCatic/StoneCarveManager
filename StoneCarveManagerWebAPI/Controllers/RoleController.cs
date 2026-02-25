using FluentValidation;
using Microsoft.AspNetCore.Mvc;
using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.IServices;

namespace StoneCarveManagerWebAPI.Controllers
{
    public class RoleController
        : BaseCRUDController<RoleResponse, RoleSearchObject, RoleInsertRequest, RoleUpdateRequest>
    {
        private readonly IRoleService _roleService;

        public RoleController(
            IRoleService service,
            IValidator<RoleInsertRequest> insertValidator,
            IValidator<RoleUpdateRequest> updateValidator)
            : base(service, insertValidator, updateValidator)
        {
            _roleService = service;
        }
    }
}