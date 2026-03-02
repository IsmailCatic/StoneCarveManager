using FluentValidation;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.IServices;
using static StoneCarveManager.Services.Constants;

namespace StoneCarveManagerWebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class BlogCategoryController
        : BaseCRUDController<BlogCategoryResponse, BlogCategorySearchObject, BlogCategoryInsertRequest, BlogCategoryUpdateRequest>
    {
        public BlogCategoryController(
            IBlogCategoryService service,
            IValidator<BlogCategoryInsertRequest> insertValidator,
            IValidator<BlogCategoryUpdateRequest> updateValidator)
            : base(service, insertValidator, updateValidator)
        {
        }

        // Override Create - Admin/Employee only
        [HttpPost]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Employee}")]
        public override async Task<BlogCategoryResponse> Create([FromBody] BlogCategoryInsertRequest request)
        {
            return await base.Create(request);
        }

        // Override Update - Admin/Employee only
        [HttpPut("{id}")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Employee}")]
        public override async Task<BlogCategoryResponse?> Update(int id, [FromBody] BlogCategoryUpdateRequest request)
        {
            return await base.Update(id, request);
        }

        // Override Delete - Admin/Employee only
        [HttpDelete("{id}")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Employee}")]
        public override async Task<bool> Delete(int id)
        {
            return await base.Delete(id);
        }
    }
}