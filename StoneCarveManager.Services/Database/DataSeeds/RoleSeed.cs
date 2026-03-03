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
                    Description = "Full system access — manage users, products, orders and content.",
                },
                new Role
                {
                    Id = -2,
                    Name = "Employee",
                    NormalizedName = "EMPLOYEE",
                    Description = "Workshop staff — process orders, upload progress images and manage inventory.",
                },
                new Role
                {
                    Id = -3,
                    Name = "User",
                    NormalizedName = "USER",
                    Description = "Registered customer — browse catalogue, place orders and write reviews.",
                }
            );
        }

        private static void SeedDefaultUserRoles(ModelBuilder builder)
        {
            builder.Entity<UserRole>().HasData(
                // Original seeded user
                new UserRole { UserId = -999,  RoleId = -1 },
                new UserRole { UserId = 1000000, RoleId = -1 },

                // Admin users
                new UserRole { UserId = -101, RoleId = -1 },
                new UserRole { UserId = -102, RoleId = -1 },
                new UserRole { UserId = -103, RoleId = -1 },

                // Employee users
                new UserRole { UserId = -201, RoleId = -2 },
                new UserRole { UserId = -202, RoleId = -2 },
                new UserRole { UserId = -203, RoleId = -2 },

                // Regular users
                new UserRole { UserId = -301, RoleId = -3 },
                new UserRole { UserId = -302, RoleId = -3 },
                new UserRole { UserId = -303, RoleId = -3 }
            );
        }
    }
}
