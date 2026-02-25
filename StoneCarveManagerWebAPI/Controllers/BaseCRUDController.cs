using FluentValidation;
using Microsoft.AspNetCore.Mvc;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.Base;

namespace StoneCarveManagerWebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class BaseCRUDController<T, TSearch, TInsert, TUpdate> : BaseController<T, TSearch>
     where T : class
     where TSearch : BaseSearchObject, new()
     where TInsert : class
     where TUpdate : class
    {
        protected readonly ICRUDService<T, TSearch, TInsert, TUpdate> _crudService;
        protected readonly IValidator<TInsert>? _insertValidator;
        protected readonly IValidator<TUpdate>? _updateValidator;

        public BaseCRUDController(
            ICRUDService<T, TSearch, TInsert, TUpdate> service,
            IValidator<TInsert>? insertValidator = null,
            IValidator<TUpdate>? updateValidator = null) : base(service)
        {
            _crudService = service;
            _insertValidator = insertValidator;
            _updateValidator = updateValidator;
        }

        [HttpPost]
        public virtual async Task<T> Create([FromBody] TInsert request)
        {
            if (_insertValidator != null)
            {
                var validationResult = await _insertValidator.ValidateAsync(request);
                if (!validationResult.IsValid)
                {
                    throw new ValidationException(validationResult.Errors);
                }
            }
            
            return await _crudService.CreateAsync(request);
        }

        [HttpPut("{id}")]
        public virtual async Task<T?> Update(int id, [FromBody] TUpdate request)
        {
            if (_updateValidator != null)
            {
                var validationResult = await _updateValidator.ValidateAsync(request);
                if (!validationResult.IsValid)
                {
                    throw new ValidationException(validationResult.Errors);
                }
            }
            
            return await _crudService.UpdateAsync(id, request);
        }

        [HttpDelete("{id}")]
        public virtual async Task<bool> Delete(int id)
        {
            return await _crudService.DeleteAsync(id);
        }
    }
}
