using Azure.Core;
using Microsoft.AspNetCore.Mvc;
using StoneCarveManager.Services.IServices;
using System.IdentityModel.Tokens.Jwt;
using StoneCarveManager.Model.Requests;

namespace StoneCarveManagerWebAPI.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;
        private readonly IUserService _userService;


        public AuthController(IAuthService authService, IUserService userService)
        {
            _authService = authService;
            _userService = userService;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest request)
        {
            var token = await _authService.Register(request);

            if (token == null)
            {
                return BadRequest("User registration failed.");
            }

            return Ok(token);
        }


        //[HttpPost("login")]
        //public async Task<IActionResult> Login([FromBody] LoginRequest request)
        //{
        //    try
        //    {
        //        var tokenResult = await _authService.Login(request);

        //        // Now you can use tokenResult.UserId
        //        await _userSessionService.TrackLoginAsync(new TrackLoginCommand
        //        {
        //            UserId = tokenResult.UserId,
        //            IpAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown",
        //            DeviceInfo = Request.Headers["User-Agent"].ToString()
        //        });

        //        return Ok(tokenResult);
        //    }
        //    catch (UnauthorizedAccessException ex)
        //    {
        //        return BadRequest(ex.Message);
        //    }
        //}

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request, CancellationToken cancellationToken)
        {
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

        // ✅ NEW: Request password reset
        [HttpPost("request-password-reset")]
        public async Task<IActionResult> RequestPasswordReset([FromBody] PasswordResetRequestRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Email))
            {
                return BadRequest(new { message = "Email is required." });
            }

            var result = await _authService.RequestPasswordResetAsync(request.Email);
            
            // Always return success for security reasons (don't reveal if user exists)
            return Ok(new 
            { 
                message = "If an account exists with this email, a password reset link has been sent." 
            });
        }

        // ✅ NEW: Confirm password reset with verification code
        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword([FromBody] PasswordResetConfirmRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Email) || 
                string.IsNullOrWhiteSpace(request.VerificationCode) || 
                string.IsNullOrWhiteSpace(request.NewPassword))
            {
                return BadRequest(new { message = "All fields are required." });
            }

            // Validate verification code format (6 digits)
            if (!System.Text.RegularExpressions.Regex.IsMatch(request.VerificationCode, @"^\d{6}$"))
            {
                return BadRequest(new { message = "Invalid verification code format. Must be 6 digits." });
            }

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
