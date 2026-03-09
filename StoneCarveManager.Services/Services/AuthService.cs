using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Services.Database.Context;
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
using RabbitMQ.Client;

namespace StoneCarveManager.Services.Services
{
    public class AuthService : IAuthService
    {
        private readonly UserManager<User> _userManager;
        private readonly RoleManager<Role> _roleManager;
        private readonly SignInManager<User> _signInManager;
        private readonly IConfiguration _configuration;
        private readonly AppDbContext _context;

        public AuthService(UserManager<User> userManager, SignInManager<User> signInManager,
            IConfiguration configuration, RoleManager<Role> roleManager,
            AppDbContext context)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _configuration = configuration;
            _roleManager = roleManager;
            _context = context;
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
                DateOfBirth = model.DateOfBirth,
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

            // Send email message via RabbitMQ
            await SendToRabbitMQ(new
            {
                Name = $"{newUser.FirstName} {newUser.LastName}",
                Email = newUser.Email,
                Role = 3, // Regular user
                Username = newUser.UserName
            });

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

            // Check if user is blocked BEFORE attempting sign-in
            if (user.IsBlocked == true)
            {
                throw new Exception("Your account has been blocked. Please contact an administrator for assistance.");
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
               new Claim("userid", user.Id.ToString()),
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
                Roles = userRoles.ToArray(),
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
                    ValidateLifetime = true,
                    ClockSkew = TimeSpan.Zero
                }, out SecurityToken validatedToken);

                return true;
            }
            catch (SecurityTokenExpiredException)
            {
                return false;
            }
            catch
            {
                return false;
            }
        }

        public async Task<bool> RequestPasswordResetAsync(string email)
        {
            var user = await _userManager.FindByEmailAsync(email);
            if (user == null)
            {
                // For security reasons, don't reveal if user exists
                return true;
            }

            // Invalidate any previous unused codes for this email
            var previousCodes = await _context.PasswordResetCodes
                .Where(c => c.Email == email.ToLower() && !c.IsUsed)
                .ToListAsync();

            foreach (var old in previousCodes)
                old.IsUsed = true;

            // Generate 6-digit verification code
            var verificationCode = Random.Shared.Next(100000, 999999).ToString();

            var expiresAt = DateTime.UtcNow.AddMinutes(15);

            // Store verification code in database
            _context.PasswordResetCodes.Add(new PasswordResetCode
            {
                Email = email.ToLower(),
                Code = verificationCode,
                ExpiresAt = expiresAt,
                CreatedAt = DateTime.UtcNow,
                IsUsed = false
            });

            await _context.SaveChangesAsync();

            // Send message to RabbitMQ for password reset email with verification code
            await SendPasswordResetToRabbitMQ(new
            {
                Name = $"{user.FirstName} {user.LastName}",
                Email = user.Email,
                VerificationCode = verificationCode,
                ResetToken = "",
                ExpiresAt = expiresAt
            });

            return true;
        }

        public async Task<bool> ResetPasswordAsync(string email, string verificationCode, string newPassword)
        {
            var user = await _userManager.FindByEmailAsync(email);
            if (user == null)
            {
                throw new Exception("Invalid password reset request.");
            }

            // Find a valid, unused, non-expired code for this email
            var resetCode = await _context.PasswordResetCodes
                .Where(c => c.Email == email.ToLower()
                         && c.Code == verificationCode
                         && !c.IsUsed
                         && c.ExpiresAt > DateTime.UtcNow)
                .OrderByDescending(c => c.CreatedAt)
                .FirstOrDefaultAsync();

            if (resetCode == null)
            {
                // Check if there's an expired code to give a better message
                var expiredCode = await _context.PasswordResetCodes
                    .AnyAsync(c => c.Email == email.ToLower()
                               && c.Code == verificationCode
                               && !c.IsUsed
                               && c.ExpiresAt <= DateTime.UtcNow);

                if (expiredCode)
                    throw new Exception("Verification code has expired. Please request a new one.");

                throw new Exception("Invalid verification code.");
            }

            // Mark code as used
            resetCode.IsUsed = true;
            await _context.SaveChangesAsync();

            // Reset password using ASP.NET Identity
            var token = await _userManager.GeneratePasswordResetTokenAsync(user);
            var result = await _userManager.ResetPasswordAsync(user, token, newPassword);
            
            if (!result.Succeeded)
            {
                var errors = string.Join(", ", result.Errors.Select(e => e.Description));
                throw new Exception($"Password reset failed: {errors}");
            }

            return true;
        }

        // Helper method for sending messages to RabbitMQ
        private async Task SendToRabbitMQ(object message)
        {
            try
            {
                var factory = new ConnectionFactory()
                {
                    HostName = _configuration["RabbitMQ:HostName"] ?? "localhost",
                    Port = int.Parse(_configuration["RabbitMQ:Port"] ?? "5672"),
                    UserName = _configuration["RabbitMQ:UserName"] ?? "guest",
                    Password = _configuration["RabbitMQ:Password"] ?? "guest"
                };
                
                await using var connection = await factory.CreateConnectionAsync();
                await using var channel = await connection.CreateChannelAsync();
                
                await channel.QueueDeclareAsync(queue: "user-registration",
                                     durable: false,
                                     exclusive: false,
                                     autoDelete: false,
                                     arguments: null);

                var json = System.Text.Json.JsonSerializer.Serialize(message);
                var body = Encoding.UTF8.GetBytes(json);

                await channel.BasicPublishAsync(exchange: "",
                                     routingKey: "user-registration",
                                     body: body);
                
                Console.WriteLine($"✅ Sent message to RabbitMQ: {json}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Failed to send to RabbitMQ: {ex.Message}");
            }
        }

        // Helper method for sending password reset messages to RabbitMQ
        private async Task SendPasswordResetToRabbitMQ(object message)
        {
            try
            {
                var factory = new ConnectionFactory()
                {
                    HostName = _configuration["RabbitMQ:HostName"] ?? "localhost",
                    Port = int.Parse(_configuration["RabbitMQ:Port"] ?? "5672"),
                    UserName = _configuration["RabbitMQ:UserName"] ?? "guest",
                    Password = _configuration["RabbitMQ:Password"] ?? "guest"
                };
                
                await using var connection = await factory.CreateConnectionAsync();
                await using var channel = await connection.CreateChannelAsync();
                
                await channel.QueueDeclareAsync(queue: "password-reset",
                                     durable: false,
                                     exclusive: false,
                                     autoDelete: false,
                                     arguments: null);

                var json = System.Text.Json.JsonSerializer.Serialize(message);
                var body = Encoding.UTF8.GetBytes(json);

                await channel.BasicPublishAsync(exchange: "",
                                     routingKey: "password-reset",
                                     body: body);
                
                Console.WriteLine($"✅ Sent password reset message to RabbitMQ: {json}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Failed to send password reset to RabbitMQ: {ex.Message}");
            }
        }
    }
}
