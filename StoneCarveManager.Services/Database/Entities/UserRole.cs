using Microsoft.AspNetCore.Identity;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.Database.Entities
{
    public class UserRole : IdentityUserRole<int>
    {
        public DateTime DateAssigned { get; set; } = DateTime.UtcNow;
        public virtual User User { get; set; } = null!;
        public virtual Role Role { get; set; } = null!;
    }
}
