using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Model.Responses
{
    public class UserDTO
    {
        public int Id { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string? ProfileImageUrl { get; set; }
        public bool IsActive { get; set; }
        public bool IsBlocked { get; set; }
        public string Email { get; set; }
        public string? PhoneNumber { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? LastLoginAt { get; set; }
        public List<string> Roles { get; set; } = new List<string>();

        // Sync version - bez roles
        //public static UserDTO FromUser(User user)
        //{
        //    if (user == null)
        //    {
        //        throw new ArgumentNullException(nameof(user), "User cannot be null");
        //    }

        //    return new UserDTO
        //    {
        //        Id = user.Id,
        //        FirstName = user.FirstName ?? string.Empty,
        //        LastName = user.LastName ?? string.Empty,
        //        ProfileImageUrl = user.ProfileImageUrl,
        //        IsActive = user.IsActive,
        //        IsBlocked = user.IsBlocked,
        //        Email = user.Email ?? string.Empty,
        //        PhoneNumber = user.PhoneNumber,
        //        CreatedAt = user.CreatedAt,
        //        LastLoginAt = user.LastLoginAt,
        //        Roles = new List<string>() // Prazna lista - popunit će se async metodom
        //    };
        //}

        //// Async version - SA roles preko UserManager
        //public static async Task<UserDTO> FromUserAsync(User user, UserManager<User> userManager)
        //{
        //    if (user == null)
        //    {
        //        throw new ArgumentNullException(nameof(user), "User cannot be null");
        //    }

        //    var roles = await userManager.GetRolesAsync(user);

        //    return new UserDTO
        //    {
        //        Id = user.Id,
        //        FirstName = user.FirstName ?? string.Empty,
        //        LastName = user.LastName ?? string.Empty,
        //        ProfileImageUrl = user.ProfileImageUrl,
        //        IsActive = user.IsActive,
        //        IsBlocked = user.IsBlocked,
        //        Email = user.Email ?? string.Empty,
        //        PhoneNumber = user.PhoneNumber,
        //        CreatedAt = user.CreatedAt,
        //        LastLoginAt = user.LastLoginAt,
        //        Roles = roles.ToList()
        //    };
        //}
    }


}
