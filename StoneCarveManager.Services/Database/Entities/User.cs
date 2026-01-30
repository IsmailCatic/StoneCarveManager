using Microsoft.AspNetCore.Identity;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.Database.Entities
{
    public class User : IdentityUser<int>
    {
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public bool IsActive { get; set; } = true;
        public bool IsBlocked { get; set; } = false;
        public string? ProfileImageUrl { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? LastLoginAt { get; set; }
        public DateTime? DateOfBirth { get; set; }
        public virtual ICollection<UserRole> UserRoles { get; set; }


        // Navigation property for the many-to-many relationship with Role
        //public ICollection<UserRole> UserRoles { get; set; } = new List<UserRole>();
        //public ICollection<Order> Orders { get; set; } = new List<Order>();
        //public ICollection<ProductReview> Reviews { get; set; } = new List<ProductReview>();
        //public ICollection<FavoriteProduct> FavoriteProducts { get; set; } = new List<FavoriteProduct>();
        //public Cart? Cart { get; set; } //(1:1) relationship
    }
}
