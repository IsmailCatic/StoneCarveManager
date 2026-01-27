using FluentValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.IServices;
using static StoneCarveManager.Model.Requests.UserRequests;
using static StoneCarveManager.Services.Constants;

namespace StoneCarveManagerWebAPI.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class UserController : ControllerBase
    {
        private readonly IUserService _userService;
        private readonly IValidator<UserInsertRequest> _insertValidator;
        private readonly IValidator<UserUpdateRequest> _updateValidator;

        public UserController(IUserService userService, 
            IValidator<UserInsertRequest> insertValidator,
            IValidator<UserUpdateRequest> updateValidator)
        {
            _userService = userService;
            _insertValidator = insertValidator;
            _updateValidator = updateValidator;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<UserDTO>>> GetAll([FromQuery] UserSearchObject? search, CancellationToken cancellationToken)
        {
            var result = await _userService.GetAsync(search ?? new UserSearchObject(), cancellationToken);
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<UserDTO>> GetByIdAsync(int id, CancellationToken cancellationToken)
        {
            var result = await _userService.GetByIdAsync(id, cancellationToken);
            return Ok(result);
        }

        [HttpGet("by-firstname/{firstName}")]
        public async Task<ActionResult<UserDTO>> GetByFirstNameAsync(string firstName, CancellationToken cancellationToken)
        {
            var result = await _userService.GetByFirstNameAsync(firstName, cancellationToken);

            if (result == null)
            {
                return NotFound("No users found with the specified first name.");
            }

            return Ok(result);
        }

        [HttpGet("by-email/{email}")]
        public async Task<ActionResult<UserDTO>> GetByEmailAsync(string email, CancellationToken cancellationToken)
        {
            var result = await _userService.GetByEmailAsync(email, cancellationToken);

            if (result == null)
            {
                return NotFound("No users found with the specified email.");
            }

            return Ok(result);
        }

        [HttpPost("by-usernames")]
        public async Task<ActionResult<List<UserDTO>>> GetByUsernamesAsync([FromBody] List<string> usernames, CancellationToken cancellationToken)
        {
            var result = await _userService.GetByUsernamesAsync(usernames, cancellationToken);
            return Ok(result);
        }

        [Authorize(Roles = $"{Roles.Admin},{Roles.Employee}")]
        [HttpDelete("delete-user/{id}")]
        public async Task<IActionResult> DeleteUser(int id, CancellationToken cancellationToken)
        {
            await _userService.DeleteAsync(id, cancellationToken);
            return Ok(new { Message = "User deleted successfully" });
        }

        [Authorize(Roles = Roles.Admin)]
        [HttpPost("add-user")]
        public async Task<IActionResult> AddUser([FromBody] UserInsertRequest insertRequest, CancellationToken cancellationToken)
        {
            var validationResult = await _insertValidator.ValidateAsync(insertRequest, cancellationToken);
            if (!validationResult.IsValid)
                return BadRequest(validationResult.Errors);

            await _userService.AddAsync(insertRequest, cancellationToken);
            return Ok(new { Message = "User added successfully" });
        }

        [Authorize(Roles = $"{Roles.Admin},{Roles.Employee}")]
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] UserUpdateRequest updateRequest, CancellationToken cancellationToken)
        {
            var validationResult = await _updateValidator.ValidateAsync(updateRequest, cancellationToken);
            if (!validationResult.IsValid)
                return BadRequest(validationResult.Errors);

            var result = await _userService.UpdateAsync(id, updateRequest, cancellationToken);
            return Ok(result);
        }
    }
}
