using FluentValidation;
using Microsoft.AspNetCore.Mvc;
using StoneCarveManager.Services.IServices;
using StoneCarveManager.Model.Requests;

namespace StoneCarveManagerWebAPI.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;
        private readonly IUserService _userService;
        private readonly IValidator<RegisterRequest> _registerValidator;
        private readonly IValidator<LoginRequest> _loginValidator;
        private readonly IValidator<PasswordResetRequestRequest> _passwordResetRequestValidator;
        private readonly IValidator<PasswordResetConfirmRequest> _passwordResetConfirmValidator;

        public AuthController(
            IAuthService authService, 
            IUserService userService,
            IValidator<RegisterRequest> registerValidator,
            IValidator<LoginRequest> loginValidator,
            IValidator<PasswordResetRequestRequest> passwordResetRequestValidator,
            IValidator<PasswordResetConfirmRequest> passwordResetConfirmValidator)
        {
            _authService = authService;
            _userService = userService;
            _registerValidator = registerValidator;
            _loginValidator = loginValidator;
            _passwordResetRequestValidator = passwordResetRequestValidator;
            _passwordResetConfirmValidator = passwordResetConfirmValidator;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest request, CancellationToken cancellationToken)
        {
            var validationResult = await _registerValidator.ValidateAsync(request, cancellationToken);
            if (!validationResult.IsValid)
                return BadRequest(new { errors = validationResult.Errors.Select(e => new { field = e.PropertyName, message = e.ErrorMessage }) });

            var token = await _authService.Register(request);

            if (token == null)
            {
                return BadRequest(new { message = "User registration failed." });
            }

            return Ok(token);
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request, CancellationToken cancellationToken)
        {
            var validationResult = await _loginValidator.ValidateAsync(request, cancellationToken);
            if (!validationResult.IsValid)
                return BadRequest(new { errors = validationResult.Errors.Select(e => new { field = e.PropertyName, message = e.ErrorMessage }) });

            try
            {
                var tokenResult = await _authService.Login(request);
                return Ok(tokenResult);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("logout")]
        public async Task<IActionResult> Logout()
        {
            return Ok(new { message = "Logged out successfully" });
        }

        [HttpPost("request-password-reset")]
        public async Task<IActionResult> RequestPasswordReset([FromBody] PasswordResetRequestRequest request, CancellationToken cancellationToken)
        {
            var validationResult = await _passwordResetRequestValidator.ValidateAsync(request, cancellationToken);
            if (!validationResult.IsValid)
                return BadRequest(new { errors = validationResult.Errors.Select(e => new { field = e.PropertyName, message = e.ErrorMessage }) });

            var result = await _authService.RequestPasswordResetAsync(request.Email);
            
            // Always return success for security reasons (don't reveal if user exists)
            return Ok(new 
            { 
                message = "If an account exists with this email, a password reset link has been sent." 
            });
        }

        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword([FromBody] PasswordResetConfirmRequest request, CancellationToken cancellationToken)
        {
            var validationResult = await _passwordResetConfirmValidator.ValidateAsync(request, cancellationToken);
            if (!validationResult.IsValid)
                return BadRequest(new { errors = validationResult.Errors.Select(e => new { field = e.PropertyName, message = e.ErrorMessage }) });

            try
            {
                var result = await _authService.ResetPasswordAsync(request.Email, request.VerificationCode, request.NewPassword);
                return Ok(new { message = "Password has been successfully changed. You can now log in with your new password." });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}
