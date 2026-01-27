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
            // Jednostavno vraćamo OK - logout je client-side (brisanje tokena iz localStorage/cookies)
            return Ok(new { message = "Logged out successfully" });
        }


        //[HttpPost("logout")]
        //public async Task<IActionResult> Logout()
        //{
        //    // Step 1: Try to get user from token (works for valid tokens)
        //    var userId = _currentUser.Id;

        //    if (userId.HasValue)
        //    {
        //        await _userSessionService.TrackLogoutAsync(userId.Value);
        //        return Ok(new { message = "Logged out successfully" });
        //    }

        //    // Step 2: For expired tokens, try to extract userId from the expired token
        //    try
        //    {
        //        var authHeader = Request.Headers["Authorization"].FirstOrDefault()?.Split(" ").Last();
        //        if (!string.IsNullOrEmpty(authHeader))
        //        {
        //            // Try to decode the token even if expired
        //            var handler = new JwtSecurityTokenHandler();
        //            var jsonToken = handler.ReadToken(authHeader) as JwtSecurityToken;

        //            // Extract user ID from token claims
        //            var userIdClaim = jsonToken?.Claims.FirstOrDefault(c => c.Type == "userid");
        //            if (userIdClaim != null && int.TryParse(userIdClaim.Value, out int tokenUserId))
        //            {
        //                await _userSessionService.TrackLogoutAsync(tokenUserId);
        //                return Ok(new { message = "Logged out successfully using token claims" });
        //            }
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        // Token parsing failed, continue to next step
        //        Console.WriteLine($"Token parsing failed: {ex.Message}");
        //    }

        //    // Step 3: Just acknowledge logout without tracking it
        //    return Ok(new { message = "Logged out client-side only" });
        //}
    }
}
