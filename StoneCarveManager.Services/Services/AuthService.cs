using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Services.Database.Entities;
using StoneCarveManager.Services.IServices;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;
using static StoneCarveManager.Services.Constants;

namespace StoneCarveManager.Services.Services
{
    public class AuthService : IAuthService
    {
        private readonly UserManager<User> _userManager;
        private readonly RoleManager<Role> _roleManager;
        private readonly SignInManager<User> _signInManager;
        private readonly IConfiguration _configuration;

        public AuthService(UserManager<User> userManager, SignInManager<User> signInManager,
            IConfiguration configuration, RoleManager<Role> roleManager
              )
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _configuration = configuration;
            _roleManager = roleManager;
        }

        public async Task<TokenDTO> Register(RegisterRequest model)
        {
            var existingUser = await _userManager.FindByEmailAsync(model.Email);
            if (existingUser != null)
            {
                throw new System.Exception("User with this email already exists");
            }



            var newUser = new User
            {
                FirstName = model.FirstName,
                LastName = model.LastName,
                Email = model.Email,
                UserName = model.Email,
                //ProfilePicture = model.ProfilePictureBytes,
                DateOfBirth = model.DateOfBirth,
                //CountryId = model.CountryId,
                //CityId = model.CityId,
                //GenderId = model.GenderId,
                //SecurityQuestions = securityQuestions,
            };


            var result = await _userManager.CreateAsync(newUser, model.Password);
            if (!result.Succeeded)
            {
                var combinedErrors = string.Join("\n", result.Errors.Select(e => e.Description));
                throw new Exception(combinedErrors);
            }
            var role = await _roleManager.FindByNameAsync(Roles.User);
            if (role == null)
            {
                throw new System.Exception("User registration failed");
            }

            var userAddedToRole = await _userManager.AddToRoleAsync(newUser, role.Name);
            if (!userAddedToRole.Succeeded)
            {
                throw new System.Exception("User registration failed");
            }


            //if (model.ProfilePictureBytes != null)
            //{
            //    await _photoService.UploadProfilePictureAsync(newUser.Id, model.ProfilePictureBytes);
            //}


            var token = await GenerateJwtTokenAsync(newUser);

            return token;
        }

        public async Task<TokenDTO> Login(LoginRequest model)
        {
            var user = await _userManager.FindByEmailAsync(model.Email);
            if (user == null)
            {
                throw new UnauthorizedAccessException("Invalid username or password");
            }


            var result = await _signInManager.PasswordSignInAsync(user, model.Password, isPersistent: false, lockoutOnFailure: false);
            if (!result.Succeeded)
            {
                throw new UnauthorizedAccessException("Invalid username or password");
            }

            var token = await GenerateJwtTokenAsync(user);

            return token;
        }

        private async Task<TokenDTO> GenerateJwtTokenAsync(User user)
        {
            var claims = new[]
            {
               new Claim(JwtRegisteredClaimNames.Sub, user.Email),
               new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
               new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
               new Claim("userid", user.Id.ToString()), // custom claim
               new Claim(ClaimTypes.Name, user.UserName),
               new Claim("firstname", $"{user.FirstName}")
            };

            // Add roles
            var userRoles = await _userManager.GetRolesAsync(user);
            foreach (var role in userRoles)
            {
                claims = [.. claims, new Claim(ClaimTypes.Role, role)];
            }

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["AuthSettings:SecretKey"]));

            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var expiry = DateTime.Now.AddHours(2);
            //var expiry = DateTime.Now.AddMinutes(1);

            var token = new JwtSecurityToken(

                issuer: _configuration["AuthSettings:Issuer"],
                claims: claims,
                expires: expiry,
                signingCredentials: creds
            );


            var tokenModel = new TokenDTO
            {
                Token = new JwtSecurityTokenHandler().WriteToken(token),
                UserId = user.Id,
                ValidTo = expiry,
                Role = userRoles.ToArray(),
            };

            return tokenModel;
        }


        public bool ValidateJwtToken(string token)
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var key = Encoding.UTF8.GetBytes(_configuration["AuthSettings:SecretKey"]);

            try
            {
                tokenHandler.ValidateToken(token, new TokenValidationParameters
                {
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(key),
                    ValidateIssuer = true,
                    ValidIssuer = _configuration["AuthSettings:Issuer"],
                    ValidateAudience = false,
                    ValidateLifetime = true, // Ovdje se provjerava istek
                    ClockSkew = TimeSpan.Zero // Bez dodatnog vremena tolerancije
                }, out SecurityToken validatedToken);

                return true;
            }
            catch (SecurityTokenExpiredException)
            {
                // Token timed out
                return false;
            }
            catch
            {
                // invalid token
                return false;
            }
        }
    }
}
