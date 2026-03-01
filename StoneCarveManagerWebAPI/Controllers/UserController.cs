using FluentValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.IServices;
using static StoneCarveManager.Model.Requests.UserRequests;
using static StoneCarveManager.Services.Constants;
using StoneCarveManager.Model.Requests;

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
        [Authorize(Roles = Roles.Admin)]
        public async Task<ActionResult<PagedResult<UserDTO>>> GetAll([FromQuery] UserSearchObject? search, CancellationToken cancellationToken)
        {
            var result = await _userService.GetAsync(search ?? new UserSearchObject(), cancellationToken);
            return Ok(result);
        }

        [HttpGet("employees")]
        [Authorize(Roles = Roles.Admin)]
        public async Task<ActionResult<List<UserDTO>>> GetEmployees(CancellationToken cancellationToken)
        {
            var employees = await _userService.GetEmployeesAsync(cancellationToken);
            return Ok(employees);
        }

        [HttpGet("{id}")]
        [Authorize]
        public async Task<ActionResult<UserDTO>> GetByIdAsync(int id, CancellationToken cancellationToken)
        {
            // Get current user ID from JWT token
            var userIdClaim = User.FindFirst("userid")?.Value;

            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var currentUserId))
            {
                return Unauthorized(new { message = "Invalid user token" });
            }

            // Check roles
            var isAdmin = User.IsInRole(Roles.Admin);

            // Rules:
            // - Admin can view any user
            // - Any authenticated user can view their own profile
            if (id != currentUserId && !isAdmin)
            {
                return Forbid();
            }

            var result = await _userService.GetByIdAsync(id, cancellationToken);
            
            if (result == null)
            {
                return NotFound(new { message = "User not found" });
            }

            return Ok(result);
        }

        [HttpGet("by-firstname/{firstName}")]
        [Authorize(Roles = Roles.Admin)]
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
        [Authorize(Roles = Roles.Admin)]
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
        [Authorize(Roles = Roles.Admin)]
        public async Task<ActionResult<List<UserDTO>>> GetByUsernamesAsync([FromBody] List<string> usernames, CancellationToken cancellationToken)
        {
            var result = await _userService.GetByUsernamesAsync(usernames, cancellationToken);
            return Ok(result);
        }

        [Authorize(Roles = Roles.Admin)]
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
                return BadRequest(new { errors = validationResult.Errors.Select(e => new { field = e.PropertyName, message = e.ErrorMessage }) });

            await _userService.AddAsync(insertRequest, cancellationToken);
            return Ok(new { message = "User added successfully" });
        }

        // ✅ PUT za update korisnika (sa sigurnosnim provjerama)
        [HttpPut("{id}")]
        [Authorize] // Bilo ko sa JWT token-om
        public async Task<IActionResult> Update(int id, [FromBody] UserUpdateRequest updateRequest, CancellationToken cancellationToken)
        {
            var validationResult = await _updateValidator.ValidateAsync(updateRequest, cancellationToken);
            if (!validationResult.IsValid)
                return BadRequest(new { errors = validationResult.Errors.Select(e => new { field = e.PropertyName, message = e.ErrorMessage }) });

            // Uzmi user ID iz custom "userid" claim-a
            var userIdClaim = User.FindFirst("userid")?.Value;

            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var currentUserId))
            {
                return Unauthorized(new { message = "Invalid user token" });
            }

            // Provjeri da li je Admin ili Employee
            var isAdmin = User.IsInRole(Roles.Admin);
            var isEmployee = User.IsInRole(Roles.Employee);

            // rules:
            // - User can update only his profile
            // - Admin & Employee can update any  profile
            if (id != currentUserId && !isAdmin && !isEmployee)
            {
                return Forbid();
            }

            var result = await _userService.UpdateAsync(id, updateRequest, cancellationToken);
            return Ok(result);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Delete(int id, CancellationToken cancellationToken)
        {
            var result = await _userService.DeleteAsync(id, cancellationToken);
            return Ok(new { message = "User deleted successfully" });
        }

        [HttpGet("current")]
        [Authorize]
        public async Task<IActionResult> GetCurrentUser(CancellationToken cancellationToken)
        {
            // Uzmi user ID iz custom "userid" claim-a
            var userIdClaim = User.FindFirst("userid")?.Value;

            if (string.IsNullOrEmpty(userIdClaim))
            {
                // Debug: Log sve claims da vidimo šta zapravo postoji
                var allClaims = User.Claims.Select(c => $"{c.Type}: {c.Value}").ToList();
                Console.WriteLine("Available claims: " + string.Join(", ", allClaims));
                
                return Unauthorized(new { 
                    message = "Invalid user token - User ID claim not found",
                    availableClaims = allClaims // ← Debug info
                });
            }

            if (!int.TryParse(userIdClaim, out var userId))
            {
                return Unauthorized(new { message = "Invalid user ID format" });
            }

            var user = await _userService.GetCurrentUserAsync(userId, cancellationToken);
            if (user == null)
            {
                return NotFound(new { message = "User not found" });
            }

            return Ok(user);
        }

        [HttpPost("change-password")]
        [Authorize]
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest request, CancellationToken cancellationToken)
        {
            if (string.IsNullOrWhiteSpace(request.CurrentPassword) || string.IsNullOrWhiteSpace(request.NewPassword))
            {
                return BadRequest(new { message = "Current password and new password are required." });
            }

            // Uzmi user ID iz custom "userid" claim-a
            var userIdClaim = User.FindFirst("userid")?.Value;

            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
            {
                return Unauthorized(new { message = "Invalid user token" });
            }

            try
            {
                var result = await _userService.ChangePasswordAsync(userId, request.CurrentPassword, request.NewPassword, cancellationToken);
                return Ok(new { message = "Password changed successfully" });
            }
            catch (UnauthorizedAccessException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        /// Upload user profile image
        /// Replaces existing image if present
        /// <returns>URL of uploaded image</returns>
        [HttpPost("{id}/profile-image")]
        [Authorize]
        public async Task<IActionResult> UploadProfileImage(
            int id,
            [FromForm] UserProfileImageUploadRequest request,
            CancellationToken cancellationToken = default)
        {
            try
            {
                // Uzmi user ID iz custom "userid" claim-a
                var userIdClaim = User.FindFirst("userid")?.Value;

                if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var currentUserId))
                {
                    return Unauthorized(new { message = "Invalid user token" });
                }

                // Provjeri da li je Admin ili Employee
                var isAdmin = User.IsInRole(Roles.Admin);
                var isEmployee = User.IsInRole(Roles.Employee);

                // Pravila:
                // - User može upload-ovati samo svoju profilnu sliku
                // - Admin i Employee mogu upload-ovati bilo čiju profilnu sliku
                if (id != currentUserId && !isAdmin && !isEmployee)
                {
                    return Forbid();
                }

                var imageUrl = await _userService.UploadUserProfileImageAsync(id, request, cancellationToken);
                return Ok(new { imageUrl });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Delete user profile image
        /// Sets ProfileImageUrl to null
        /// </summary>
        /// <param name="id">User ID</param>
        /// <param name="cancellationToken"></param>
        [HttpDelete("{id}/profile-image")]
        [Authorize]
        public async Task<IActionResult> DeleteProfileImage(
            int id,
            CancellationToken cancellationToken = default)
        {
            // Uzmi user ID iz custom "userid" claim-a
            var userIdClaim = User.FindFirst("userid")?.Value;

            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var currentUserId))
            {
                return Unauthorized(new { message = "Invalid user token" });
            }

            // Provjeri da li je Admin ili Employee
            var isAdmin = User.IsInRole(Roles.Admin);
            var isEmployee = User.IsInRole(Roles.Employee);

            // Pravila:
            // - User može obrisati samo svoju profilnu sliku
            // - Admin i Employee mogu obrisati bilo čiju profilnu sliku
            if (id != currentUserId && !isAdmin && !isEmployee)
            {
                return Forbid();
            }

            var deleted = await _userService.DeleteUserProfileImageAsync(id, cancellationToken);
            
            if (!deleted)
                return NotFound(new { message = "User not found or no profile image to delete" });
            
            return NoContent();
        }
    }
}
