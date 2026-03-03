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
using RabbitMQ.Client;

namespace StoneCarveManager.Services.Services
{
    public class AuthService : IAuthService
    {
        private readonly UserManager<User> _userManager;
        private readonly RoleManager<Role> _roleManager;
        private readonly SignInManager<User> _signInManager;
        private readonly IConfiguration _configuration;
        
        // ✅ In-memory cache for verification codes (Development only)
        // TODO: Replace with Redis in production
        private static readonly Dictionary<string, (string Code, DateTime ExpiresAt)> _verificationCodes 
            = new Dictionary<string, (string Code, DateTime ExpiresAt)>();

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
            SendToRabbitMQ(new
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

            var result = await _signInManager.PasswordSignInAsync(user, model.Password, isPersistent: false, lockoutOnFailure: false);
            if (!result.Succeeded)
            {
                throw new UnauthorizedAccessException("Invalid username or password");
            }

            // ⭐ Check if user is blocked
            if (user.IsBlocked == true)
            {
                throw new Exception("Your account has been blocked. Please contact an administrator for assistance.");
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
                Roles = userRoles.ToArray(), // ✅ Promijenjeno sa Role na Roles
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

        // ✅ NEW: Request password reset with verification code
        public async Task<bool> RequestPasswordResetAsync(string email)
        {
            var user = await _userManager.FindByEmailAsync(email);
            if (user == null)
            {
                // For security reasons, don't reveal if user exists
                return true;
            }

            // Generate 6-digit verification code
            var random = new Random();
            var verificationCode = random.Next(100000, 999999).ToString();

            // ✅ Store verification code in memory with 1 hour expiration
            var expiresAt = DateTime.UtcNow.AddHours(1);
            _verificationCodes[email.ToLower()] = (verificationCode, expiresAt);

            Console.WriteLine($"✅ Stored verification code for {email}: {verificationCode} (expires at {expiresAt})");

            // Send message to RabbitMQ for password reset email with verification code
            SendPasswordResetToRabbitMQ(new
            {
                Name = $"{user.FirstName} {user.LastName}",
                Email = user.Email,
                VerificationCode = verificationCode,
                ResetToken = "",  // Not used anymore
                ExpiresAt = expiresAt
            });

            return true;
        }

        // ✅ NEW: Confirm password reset with verification code
        public async Task<bool> ResetPasswordAsync(string email, string verificationCode, string newPassword)
        {
            var user = await _userManager.FindByEmailAsync(email);
            if (user == null)
            {
                throw new Exception("Invalid password reset request.");
            }

            // ✅ Validate verification code from memory
            var emailKey = email.ToLower();
            
            if (!_verificationCodes.ContainsKey(emailKey))
            {
                throw new Exception("No verification code found. Please request a new one.");
            }

            var (storedCode, expiresAt) = _verificationCodes[emailKey];

            // Check if code expired
            if (DateTime.UtcNow > expiresAt)
            {
                _verificationCodes.Remove(emailKey);
                throw new Exception("Verification code has expired. Please request a new one.");
            }

            // Check if code matches
            if (storedCode != verificationCode)
            {
                throw new Exception("Invalid verification code.");
            }

            Console.WriteLine($"✅ Verification code valid for {email}. Resetting password...");

            // Remove used code
            _verificationCodes.Remove(emailKey);

            // Reset password using ASP.NET Identity
            var token = await _userManager.GeneratePasswordResetTokenAsync(user);
            var result = await _userManager.ResetPasswordAsync(user, token, newPassword);
            
            if (!result.Succeeded)
            {
                var errors = string.Join(", ", result.Errors.Select(e => e.Description));
                throw new Exception($"Password reset failed: {errors}");
            }

            Console.WriteLine($"✅ Password successfully reset for {email}");

            return true;
        }

        // Helper method for sending messages to RabbitMQ
        private async void SendToRabbitMQ(object message)
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
        private async void SendPasswordResetToRabbitMQ(object message)
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
