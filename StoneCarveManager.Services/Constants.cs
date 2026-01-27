using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Services
{
    public static class Constants
    {
        public static class Policies
        {
            public static readonly string DefaultCORSPolicyName = "StoneCarveManager_CorsPolicy";
        }

        public static class Roles
        {
            public const string Admin = "Admin";
            public const string Employee = "Employee";
            public const string User = "User";
        }

        public static class AuthorizationPolicies
        {
            public const string Admin = "AdminCanAccess";
            public const string Employee = "EmployeeCanAccess";
            public const string User = "UserCanAccess";
        }

        public static class RoleIds
        {
            public static readonly int Admin = -1;
            public static readonly int Employee = -2;
            public static readonly int User = -3;
        }
    }
}
