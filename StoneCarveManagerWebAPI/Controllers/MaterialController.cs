using Microsoft.AspNetCore.Mvc;
using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.IServices;

namespace StoneCarveManagerWebAPI.Controllers
{
    public class MaterialController
        : BaseCRUDController<MaterialResponse, MaterialSearchObject, MaterialInsertRequest, MaterialUpdateRequest>
    {
        private readonly IMaterialService _materialService;

        public MaterialController(IMaterialService service) : base(service)
        {
            _materialService = service;
        }
    }
}
