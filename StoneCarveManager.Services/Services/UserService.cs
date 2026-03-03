using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MapsterMapper;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using RabbitMQ.Client;
using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.Database.Context;
using StoneCarveManager.Services.Database.Entities;
using StoneCarveManager.Services.IServices;
using static StoneCarveManager.Model.Requests.UserRequests;
using static StoneCarveManager.Services.Constants;

namespace StoneCarveManager.Services.Services
{
    public class UserService : IUserService
    {
        private readonly AppDbContext _context;
        private readonly UserManager<User> _userManager;
        private readonly RoleManager<Role> _roleManager;
        protected readonly IMapper _mapper;
        private readonly IFileService _fileService;
        private readonly IConfiguration _configuration;

        public UserService(AppDbContext context, UserManager<User> userManager,
            RoleManager<Role> roleManager, IMapper mapper, IFileService fileService, IConfiguration configuration)
        {
            _userManager = userManager;
            _context = context;
            _roleManager = roleManager;
            _mapper = mapper;
            _fileService = fileService;
            _configuration = configuration;
        }

        public async Task<PagedResult<UserDTO>> GetAsync(UserSearchObject search, CancellationToken cancellationToken)
        {
            var query = _context.Users
                .AsNoTracking()
                .Include(u => u.UserRoles)
                    .ThenInclude(ur => ur.Role)
                .AsQueryable();

            // Apply filters
            query = ApplyFilter(query, search);

            var result = new PagedResult<UserDTO>();

            // If retrieve all is requested
            if (search.RetrieveAll)
            {
                var allUsers = await query.ToListAsync(cancellationToken);
                result.Items = await MapToDTOAsync(allUsers, cancellationToken);
                return result;
            }

            // Count total
            result.TotalCount = await query.CountAsync(cancellationToken);

            //if (search.IncludeTotalCount)
            //    result.IncludeTotalCount = true;

            // Apply pagination
            if (search.Page.HasValue && search.Page > 0)
            {
                query = query.Skip(((search.Page ?? 1) - 1) * (search.PageSize ?? 10));
            }

            if (search.PageSize.HasValue)
            {
                query = query.Take(search.PageSize ?? 10);
            }

            var pagedUsers = await query.ToListAsync(cancellationToken);
            result.Items = await MapToDTOAsync(pagedUsers, cancellationToken);

            return result;
        }

        private IQueryable<User> ApplyFilter(IQueryable<User> query, UserSearchObject? search)
        {
            if (search == null)
                return query;

            // FTS search (Full Text Search - searches across multiple fields)
            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                query = query.Where(u =>
                    u.FirstName.Contains(search.FTS) ||
                    u.LastName.Contains(search.FTS) ||
                    u.Email.Contains(search.FTS) ||
                    (u.PhoneNumber != null && u.PhoneNumber.Contains(search.FTS)));
            }

            // Filter by Email (partial match)
            if (!string.IsNullOrWhiteSpace(search.Email))
            {
                query = query.Where(u => u.Email.Contains(search.Email));
            }

            // Filter by FirstName (partial match)
            if (!string.IsNullOrWhiteSpace(search.FirstName))
            {
                query = query.Where(u => u.FirstName.Contains(search.FirstName));
            }

            // Filter by LastName (partial match)
            if (!string.IsNullOrWhiteSpace(search.LastName))
            {
                query = query.Where(u => u.LastName.Contains(search.LastName));
            }

            // Filter by RoleName (case-insensitive)
            if (!string.IsNullOrWhiteSpace(search.RoleName))
            {
                query = query.Where(u => u.UserRoles.Any(ur =>
                    ur.Role != null && ur.Role.Name.ToLower() == search.RoleName.ToLower()));
            }

            return query;
        }

        public async Task<UserDTO> AddAsync(UserInsertRequest insertRequest, CancellationToken cancellationToken)
        {
            var existingUser = await _userManager.FindByEmailAsync(insertRequest.Email);
            if (existingUser != null)
            {
                throw new Exception("User with this email already exists");
            }

            var newUser = new User
            {
                FirstName = insertRequest.FirstName,
                LastName = insertRequest.LastName,
                Email = insertRequest.Email,
                UserName = insertRequest.Email,
                IsActive = insertRequest.IsActive,
                IsBlocked = insertRequest.IsBlocked,
                CreatedAt = DateTime.UtcNow
            };

            var result = await _userManager.CreateAsync(newUser, insertRequest.Password);
            if (!result.Succeeded)
            {
                throw new Exception($"User creation failed: {string.Join(", ", result.Errors.Select(e => e.Description))}");
            }

            // Add all roles that were provided
            if (insertRequest.Roles != null && insertRequest.Roles.Any())
            {
                foreach (var roleName in insertRequest.Roles)
                {
                    var role = await _roleManager.FindByNameAsync(roleName);
                    if (role == null)
                        throw new Exception($"Role '{roleName}' does not exist");

                    var addRoleResult = await _userManager.AddToRoleAsync(newUser, role.Name);
                    if (!addRoleResult.Succeeded)
                    {
                        throw new Exception($"Failed to add user to role '{roleName}': {string.Join(", ", addRoleResult.Errors.Select(e => e.Description))}");
                    }
                }

                // For RabbitMQ email - take the first (or primary) role
                var primaryRole = insertRequest.Roles.FirstOrDefault();
                if (primaryRole != null)
                {
                    int roleId = primaryRole == Roles.Admin ? 1 : (primaryRole == Roles.Employee ? 2 : 3);
                    if (roleId != 3)
                    {
                        SendToRabbitMQ(new
                        {
                            Name = $"{newUser.FirstName} {newUser.LastName}",
                            Email = newUser.Email,
                            Password = insertRequest.Password,
                            Role = roleId,
                            Username = newUser.UserName
                        });
                    }
                }
            }

            var userWithDetails = await _context.Users
                .Include(x => x.UserRoles)
                .Where(x => x.Id == newUser.Id)
                .FirstOrDefaultAsync(cancellationToken);

            if (userWithDetails == null)
            {
                throw new Exception("User not found after creation.");
            }

            return await MapToDTOAsync(userWithDetails, cancellationToken);
        }

        public async Task<bool> DeleteAsync(int id, CancellationToken cancellationToken)
        {
            var user = await _context.Users.FindAsync(new object[] { id }, cancellationToken);
            if (user == null)
            {
                throw new KeyNotFoundException($"User with ID {id} not found.");
            }

            // Soft delete — mark as inactive instead of removing from the database
            user.IsActive = false;
            await _context.SaveChangesAsync(cancellationToken);

            return true;
        }

        public async Task<ICollection<UserDTO>> GetAllAsync(CancellationToken cancellationToken)
        {
            var list = await _context.Users
                .AsNoTracking()
                .Include(u => u.UserRoles)
                    .ThenInclude(ur => ur.Role)
                .Select(u => new UserDTO
                {
                    Id = u.Id,
                    FirstName = u.FirstName,
                    LastName = u.LastName,
                    Email = u.Email,
                    ProfileImageUrl = u.ProfileImageUrl,
                    IsActive = u.IsActive,
                    PhoneNumber = u.PhoneNumber,
                    IsBlocked = u.IsBlocked,
                    CreatedAt = u.CreatedAt,
                    LastLoginAt = u.LastLoginAt,
                    Roles = u.UserRoles.Where(ur => ur.Role != null).Select(ur => ur.Role.Name).ToList()
                })
                .OrderBy(x => x.FirstName)
                .ToListAsync(cancellationToken);

            return list;
        }

        public async Task<UserDTO?> GetByFirstNameAsync(string firstName, CancellationToken cancellationToken)
        {
            var user = await _context.Users
                .AsNoTracking()
                .Include(u => u.UserRoles)
                .FirstOrDefaultAsync(u => u.FirstName == firstName, cancellationToken);

            if (user == null)
                return null;

            return await MapToDTOAsync(user, cancellationToken);
        }

        public async Task<UserDTO?> GetByIdAsync(int id, CancellationToken cancellationToken)
        {
            var user = await _context.Users
                .AsNoTracking()
                .Include(u => u.UserRoles)
                .FirstOrDefaultAsync(u => u.Id == id, cancellationToken);

            if (user == null)
                throw new KeyNotFoundException($"User with ID {id} not found.");

            return await MapToDTOAsync(user, cancellationToken);
        }

        public async Task<UserDTO?> GetByEmailAsync(string email, CancellationToken cancellationToken)
        {
            var user = await _context.Users
                .AsNoTracking()
                .Include(u => u.UserRoles)
                .FirstOrDefaultAsync(u => u.Email == email, cancellationToken);

            if (user == null)
                return null;

            return await MapToDTOAsync(user, cancellationToken);
        }

        public async Task<List<UserDTO>> GetByUsernamesAsync(List<string> usernames, CancellationToken cancellationToken)
        {
            var users = await _context.Users
                .AsNoTracking()
                .Where(u => usernames.Contains(u.UserName))
                .Include(u => u.UserRoles)
                .ToListAsync(cancellationToken);

            return await MapToDTOAsync(users, cancellationToken);
        }

        public async Task<UserDTO> UpdateAsync(int id, UserUpdateRequest updateRequest, CancellationToken cancellationToken)
        {
            var user = await _context.Users.Include(u => u.UserRoles)
                .ThenInclude(ur => ur.Role)
                .FirstOrDefaultAsync(u => u.Id == id, cancellationToken);

            if (user == null)
            {
                throw new KeyNotFoundException("User not found.");
            }

            if (!string.IsNullOrWhiteSpace(updateRequest.FirstName))
                user.FirstName = updateRequest.FirstName;

            if (!string.IsNullOrWhiteSpace(updateRequest.LastName))
                user.LastName = updateRequest.LastName;

            if (!string.IsNullOrWhiteSpace(updateRequest.Email))
                user.Email = updateRequest.Email;

            if (!string.IsNullOrWhiteSpace(updateRequest.ProfileImageUrl))
                user.ProfileImageUrl = updateRequest.ProfileImageUrl;

            if (updateRequest.IsActive.HasValue)
                user.IsActive = updateRequest.IsActive.Value;

            if (updateRequest.IsBlocked.HasValue)
                user.IsBlocked = updateRequest.IsBlocked.Value;

            if (!string.IsNullOrWhiteSpace(updateRequest.PhoneNumber))
                user.PhoneNumber = updateRequest.PhoneNumber;

            // Update roles if provided
            if (updateRequest.Roles != null && updateRequest.Roles.Any())
            {
                // Current user roles
                var currentRoleNames = user.UserRoles
                    .Where(ur => ur.Role != null)
                    .Select(ur => ur.Role.Name)
                    .ToList();
                var newRoleNames = updateRequest.Roles.ToList();

                // Roles to add (exist in newRoles but not in currentRoles)
                var rolesToAdd = newRoleNames.Except(currentRoleNames).ToList();

                // Roles to remove (exist in currentRoles but not in newRoles)
                var rolesToRemove = currentRoleNames.Except(newRoleNames).ToList();

                // Add new roles
                foreach (var roleName in rolesToAdd)
                {
                    var role = await _context.Roles.FirstOrDefaultAsync(r => r.Name.ToLower() == roleName.ToLower(), cancellationToken);
                    if (role != null)
                    {
                        user.UserRoles.Add(new UserRole
                        {
                            UserId = user.Id,
                            RoleId = role.Id,
                            Role = role
                        });
                    }
                }

                // Remove old roles
                var userRolesToRemove = user.UserRoles
                    .Where(ur => ur.Role != null && rolesToRemove.Contains(ur.Role.Name))
                    .ToList();

                foreach (var userRole in userRolesToRemove)
                {
                    user.UserRoles.Remove(userRole);
                }
            }

            await _context.SaveChangesAsync(cancellationToken);

            return await MapToDTOAsync(user, cancellationToken);
        }

        private async Task<UserDTO> MapToDTOAsync(User user, CancellationToken cancellationToken)
        {
            if (user == null)
                throw new ArgumentNullException(nameof(user));

            var roles = await _context.Roles.ToListAsync(cancellationToken);

            var dto = _mapper.Map<UserDTO>(user);

            dto.Roles = user.UserRoles
                .Select(ur => roles.FirstOrDefault(r => r.Id == ur.RoleId)?.Name ?? "")
                .ToList();

            return dto;
        }

        private async Task<List<UserDTO>> MapToDTOAsync(List<User> users, CancellationToken cancellationToken)
        {
            var roles = await _context.Roles.ToListAsync(cancellationToken);

            return users.Select(u =>
            {
                var dto = _mapper.Map<UserDTO>(u);
                dto.Roles = u.UserRoles
                    .Select(ur => roles.FirstOrDefault(r => r.Id == ur.RoleId)?.Name ?? "")
                    .ToList();
                return dto;
            }).ToList();
        }

        // Get currently logged-in user
        public async Task<UserDTO?> GetCurrentUserAsync(int userId, CancellationToken cancellationToken)
        {
            var user = await _context.Users
                .AsNoTracking()
                .Include(u => u.UserRoles)
                .FirstOrDefaultAsync(u => u.Id == userId, cancellationToken);

            if (user == null)
                return null;

            return await MapToDTOAsync(user, cancellationToken);
        }

        // Get employees (Admin + Employee roles)
        public async Task<List<UserDTO>> GetEmployeesAsync(CancellationToken cancellationToken)
        {
            var employees = await _context.Users
                .AsNoTracking()
                .Include(u => u.UserRoles)
                    .ThenInclude(ur => ur.Role)
                .Where(u => u.UserRoles.Any(ur => ur.Role != null && (ur.Role.Name == Roles.Admin || ur.Role.Name == Roles.Employee)))
                .Where(u => u.IsActive == true && u.IsBlocked == false)
                .OrderBy(u => u.FirstName)
                .ToListAsync(cancellationToken);

            return await MapToDTOAsync(employees, cancellationToken);
        }

        // Change password
        public async Task<bool> ChangePasswordAsync(int userId, string currentPassword, string newPassword, CancellationToken cancellationToken)
        {
            var user = await _userManager.FindByIdAsync(userId.ToString());
            if (user == null)
            {
                throw new KeyNotFoundException("User not found.");
            }

            // Check if current password is correct
            var currentPasswordValid = await _userManager.CheckPasswordAsync(user, currentPassword);
            if (!currentPasswordValid)
            {
                throw new UnauthorizedAccessException("Current password is incorrect.");
            }

            // Change password
            var result = await _userManager.ChangePasswordAsync(user, currentPassword, newPassword);
            if (!result.Succeeded)
            {
                var errors = string.Join(", ", result.Errors.Select(e => e.Description));
                throw new Exception($"Failed to change password: {errors}");
            }

            return true;
        }

        /// <summary>
        /// Upload user profile image to Azure Blob Storage
        /// Replaces existing image if present
        /// </summary>
        public async Task<string> UploadUserProfileImageAsync(
            int userId,
            UserProfileImageUploadRequest request,
            CancellationToken cancellationToken = default)
        {
            var user = await _context.Users.FindAsync(new object[] { userId }, cancellationToken);

            if (user == null)
                throw new KeyNotFoundException($"User with ID {userId} not found.");

            // Validate file
            if (request.File == null || request.File.Length == 0)
                throw new ArgumentException("File is required");

            // Validate file type
            var allowedExtensions = new[] { ".jpg", ".jpeg", ".png" };
            var extension = Path.GetExtension(request.File.FileName).ToLowerInvariant();

            if (!allowedExtensions.Contains(extension))
                throw new ArgumentException("Only JPG and PNG files are allowed");

            // Validate file size (max 5MB)
            if (request.File.Length > 5 * 1024 * 1024)
                throw new ArgumentException("File size must be less than 5MB");

            // Delete old image if exists
            if (!string.IsNullOrWhiteSpace(user.ProfileImageUrl))
            {
                try
                {
                    await _fileService.DeleteAsync(user.ProfileImageUrl, "user-profile-images", cancellationToken);
                }
                catch
                {
                    // Log error but continue with upload
                }
            }

            // Upload new image
            var imageUrl = await _fileService.UploadAsync(
                request.File,
                "user-profile-images",  // Container name
                null,                    // Auto-generate filename
                cancellationToken
            );

            // Update user record
            user.ProfileImageUrl = imageUrl;

            await _context.SaveChangesAsync(cancellationToken);

            return imageUrl;
        }

        /// <summary>
        /// Delete user profile image from Azure Blob Storage
        /// </summary>
        public async Task<bool> DeleteUserProfileImageAsync(
            int userId,
            CancellationToken cancellationToken = default)
        {
            var user = await _context.Users.FindAsync(new object[] { userId }, cancellationToken);

            if (user == null)
                return false;

            if (string.IsNullOrWhiteSpace(user.ProfileImageUrl))
                return false;

            try
            {
                await _fileService.DeleteAsync(user.ProfileImageUrl, "user-profile-images", cancellationToken);

                user.ProfileImageUrl = null;

                await _context.SaveChangesAsync(cancellationToken);

                return true;
            }
            catch
            {
                return false;
            }
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

                Console.WriteLine($"✅ Sent user creation message to RabbitMQ: {json}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Failed to send to RabbitMQ: {ex.Message}");
            }
        }
    }
}
