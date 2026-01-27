using Microsoft.EntityFrameworkCore;
using StoneCarveManager.Services.Database.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.Database.DataSeeds
{
    internal static class RoleSeed
    {
        public static void Seed(ModelBuilder builder)
        {
            SeedDefaultRoles(builder);
            SeedDefaultUserRoles(builder);
        }
        private static void SeedDefaultRoles(ModelBuilder builder)
        {
            builder.Entity<Role>().HasData(
                new Role
                {
                    Id = -1,
                    Name = "Admin",
                    NormalizedName = "ADMIN",
                },
                new Role
                {
                    Id = -2,
                    Name = "Employee",
                    NormalizedName = "EMPLOYEE",
                },
                new Role
                {
                    Id = -3,
                    Name = "User",
                    NormalizedName = "USER",
                }
            );
        }

        private static void SeedDefaultUserRoles(ModelBuilder builder)
        {
            builder.Entity<UserRole>().HasData(
                new UserRole
                {
                    UserId = -999,
                    RoleId = -1
                }
              
            );
        }
    }
}
