using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Model.Requests
{
    public class UserRequests
    {
        public class UserInsertRequest
        {
            public string FirstName { get; set; }
            public string LastName { get; set; }
            public string Email { get; set; }
            public string Password { get; set; } // Plaintext password for hashing during insertion
            public string? PhoneNumber { get; set; }
            public string? ProfileImageUrl { get; set; }
            public bool IsActive { get; set; } = true;
            public bool IsBlocked { get; set; } = false;
        }

        public class UserUpdateRequest
        {
            public string? FirstName { get; set; }
            public string? LastName { get; set; }
            public string? Email { get; set; }
            public string? PhoneNumber { get; set; }
            public string? ProfileImageUrl { get; set; }
            public bool? IsActive { get; set; }
            public bool? IsBlocked { get; set; }
        }

    }
}
