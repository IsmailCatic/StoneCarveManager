using MapsterMapper;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.Database.Context;
using StoneCarveManager.Services.Database.Entities;
using StoneCarveManager.Services.IServices;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
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

        public UserService(AppDbContext context, UserManager<User> userManager,
            RoleManager<Role> roleManager, IMapper mapper)
        {
            _userManager = userManager;
            _context = context;
            _roleManager = roleManager;
            _mapper = mapper;
        }

        public async Task<PagedResult<UserDTO>> GetAsync(UserSearchObject search, CancellationToken cancellationToken)
        {
            var query = _context.Users
                .AsNoTracking()
                .Include(u => u.UserRoles)
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

            // FTS search
            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                query = query.Where(u =>
                    u.FirstName.Contains(search.FTS) ||
                    u.LastName.Contains(search.FTS) ||
                    u.Email.Contains(search.FTS) ||
                    (u.PhoneNumber != null && u.PhoneNumber.Contains(search.FTS)));
            }

            // Filter by Email
            if (!string.IsNullOrWhiteSpace(search.Email))
            {
                query = query.Where(u => u.Email.Contains(search.Email));
            }

            // Filter by IsActive
            if (search.IsActive.HasValue)
            {
                query = query.Where(u => u.IsActive == search.IsActive.Value);
            }

            // Filter by IsBlocked
            if (search.IsBlocked.HasValue)
            {
                query = query.Where(u => u.IsBlocked == search.IsBlocked.Value);
            }

            // Filter by RoleId
            if (search.RoleId.HasValue)
            {
                query = query.Where(u => u.UserRoles.Any(ur => ur.RoleId == search.RoleId.Value));
            }

            return query;
        }

        public async Task<UserDTO> AddAsync(UserInsertRequest insertRequest, CancellationToken cancellationToken)
        {
            // Check if a user with the given email already exists
            var existingUser = await _userManager.FindByEmailAsync(insertRequest.Email);
            if (existingUser != null)
            {
                throw new Exception("User with this email already exists");
            }

            // Create a new user entity
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

            // Add the user to the database with the specified password
            var result = await _userManager.CreateAsync(newUser, insertRequest.Password);
            if (!result.Succeeded)
            {
                throw new Exception($"User creation failed: {string.Join(", ", result.Errors.Select(e => e.Description))}");
            }

            var role = await _roleManager.FindByNameAsync(insertRequest.Role);
            if (role == null) throw new Exception($"Role '{insertRequest.Role}' does not exist");
            //await _userManager.AddToRoleAsync(newUser, role.Name);

            // Add the user to the default "User" role
            //var role = await _roleManager.FindByNameAsync(Roles.User);
            //if (role == null)
            //{
            //    throw new Exception("Default role 'User' does not exist");
            //}

            var userAddedToRole = await _userManager.AddToRoleAsync(newUser, role.Name);
            if (!userAddedToRole.Succeeded)
            {
                throw new Exception($"Failed to add user to role: {string.Join(", ", userAddedToRole.Errors.Select(e => e.Description))}");
            }

            // Fetch user with details using DbContext
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

            _context.Users.Remove(user);
            await _context.SaveChangesAsync(cancellationToken);

            return true;
        }

        public async Task<ICollection<UserDTO>> GetAllAsync(CancellationToken cancellationToken)
        {
            var list = await _context.Users
                .AsNoTracking()
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
                    Roles = u.UserRoles.Select(ur => ur.Role.Name).ToList()
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
            var user = await _context.Users
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
    }
}
