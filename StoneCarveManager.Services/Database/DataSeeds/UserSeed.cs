using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using StoneCarveManager.Services.Database.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.Database.DataSeeds
{
    internal static class UserSeed
    {
        public static void Seed(ModelBuilder builder)
        {
            var passwordHasher = new PasswordHasher<User>();

            // ── Original seed users ──────────────────────────────────────────────
            var user1 = new User
            {
                Id = -999,
                FirstName = "Ismail",
                LastName = "Catic",
                UserName = "ismail.catic@edu.fit.ba",
                NormalizedUserName = "ISMAIL.CATIC@EDU.FIT.BA",
                Email = "ismail.catic@edu.fit.ba",
                NormalizedEmail = "ISMAIL.CATIC@EDU.FIT.BA",
                EmailConfirmed = true,
                SecurityStamp = Guid.NewGuid().ToString(),
            };
            user1.PasswordHash = passwordHasher.HashPassword(user1, "Ismail$ifr4");

            var originalAdmin = new User
            {
                Id = 1000000,
                FirstName = "Admin",
                LastName = "Admin",
                UserName = "admin@edu.fit.ba",
                NormalizedUserName = "ADMIN@EDU.FIT.BA",
                Email = "admin@edu.fit.ba",
                NormalizedEmail = "ADMIN@EDU.FIT.BA",
                EmailConfirmed = true,
                SecurityStamp = Guid.NewGuid().ToString(),
            };
            originalAdmin.PasswordHash = passwordHasher.HashPassword(originalAdmin, "test");

            // ── Admin users (Id: -101, -102, -103) ───────────────────────────────
            var admin1 = new User
            {
                Id = -101,
                FirstName = "Ana",
                LastName = "Kovač",
                UserName = "admin1@stonecarve.com",
                NormalizedUserName = "ADMIN1@STONECARVE.COM",
                Email = "admin1@stonecarve.com",
                NormalizedEmail = "ADMIN1@STONECARVE.COM",
                EmailConfirmed = true,
                IsActive = true,
                CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc),
                SecurityStamp = Guid.NewGuid().ToString(),
            };
            admin1.PasswordHash = passwordHasher.HashPassword(admin1, "Admin@1234");

            var admin2 = new User
            {
                Id = -102,
                FirstName = "Marko",
                LastName = "Petrić",
                UserName = "admin2@stonecarve.com",
                NormalizedUserName = "ADMIN2@STONECARVE.COM",
                Email = "admin2@stonecarve.com",
                NormalizedEmail = "ADMIN2@STONECARVE.COM",
                EmailConfirmed = true,
                IsActive = true,
                CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc),
                SecurityStamp = Guid.NewGuid().ToString(),
            };
            admin2.PasswordHash = passwordHasher.HashPassword(admin2, "Admin@1234");

            var admin3 = new User
            {
                Id = -103,
                FirstName = "Sara",
                LastName = "Novak",
                UserName = "admin3@stonecarve.com",
                NormalizedUserName = "ADMIN3@STONECARVE.COM",
                Email = "admin3@stonecarve.com",
                NormalizedEmail = "ADMIN3@STONECARVE.COM",
                EmailConfirmed = true,
                IsActive = true,
                CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc),
                SecurityStamp = Guid.NewGuid().ToString(),
            };
            admin3.PasswordHash = passwordHasher.HashPassword(admin3, "Admin@1234");

            // ── Employee users (Id: -201, -202, -203) ────────────────────────────
            var employee1 = new User
            {
                Id = -201,
                FirstName = "Luka",
                LastName = "Jurić",
                UserName = "employee1@stonecarve.com",
                NormalizedUserName = "EMPLOYEE1@STONECARVE.COM",
                Email = "employee1@stonecarve.com",
                NormalizedEmail = "EMPLOYEE1@STONECARVE.COM",
                EmailConfirmed = true,
                IsActive = true,
                CreatedAt = new DateTime(2024, 1, 5, 0, 0, 0, DateTimeKind.Utc),
                SecurityStamp = Guid.NewGuid().ToString(),
            };
            employee1.PasswordHash = passwordHasher.HashPassword(employee1, "Employee@1234");

            var employee2 = new User
            {
                Id = -202,
                FirstName = "Maja",
                LastName = "Horvat",
                UserName = "employee2@stonecarve.com",
                NormalizedUserName = "EMPLOYEE2@STONECARVE.COM",
                Email = "employee2@stonecarve.com",
                NormalizedEmail = "EMPLOYEE2@STONECARVE.COM",
                EmailConfirmed = true,
                IsActive = true,
                CreatedAt = new DateTime(2024, 1, 5, 0, 0, 0, DateTimeKind.Utc),
                SecurityStamp = Guid.NewGuid().ToString(),
            };
            employee2.PasswordHash = passwordHasher.HashPassword(employee2, "Employee@1234");

            var employee3 = new User
            {
                Id = -203,
                FirstName = "Tomislav",
                LastName = "Blažević",
                UserName = "employee3@stonecarve.com",
                NormalizedUserName = "EMPLOYEE3@STONECARVE.COM",
                Email = "employee3@stonecarve.com",
                NormalizedEmail = "EMPLOYEE3@STONECARVE.COM",
                EmailConfirmed = true,
                IsActive = true,
                CreatedAt = new DateTime(2024, 1, 5, 0, 0, 0, DateTimeKind.Utc),
                SecurityStamp = Guid.NewGuid().ToString(),
            };
            employee3.PasswordHash = passwordHasher.HashPassword(employee3, "Employee@1234");

            // ── Regular users (Id: -301, -302, -303) ─────────────────────────────
            var regularUser1 = new User
            {
                Id = -301,
                FirstName = "Ivan",
                LastName = "Babić",
                UserName = "user1@stonecarve.com",
                NormalizedUserName = "USER1@STONECARVE.COM",
                Email = "user1@stonecarve.com",
                NormalizedEmail = "USER1@STONECARVE.COM",
                EmailConfirmed = true,
                IsActive = true,
                CreatedAt = new DateTime(2024, 1, 10, 0, 0, 0, DateTimeKind.Utc),
                DateOfBirth = new DateTime(1990, 4, 22, 0, 0, 0, DateTimeKind.Utc),
                SecurityStamp = Guid.NewGuid().ToString(),
            };
            regularUser1.PasswordHash = passwordHasher.HashPassword(regularUser1, "User@1234");

            var regularUser2 = new User
            {
                Id = -302,
                FirstName = "Petra",
                LastName = "Knežević",
                UserName = "user2@stonecarve.com",
                NormalizedUserName = "USER2@STONECARVE.COM",
                Email = "user2@stonecarve.com",
                NormalizedEmail = "USER2@STONECARVE.COM",
                EmailConfirmed = true,
                IsActive = true,
                CreatedAt = new DateTime(2024, 1, 12, 0, 0, 0, DateTimeKind.Utc),
                DateOfBirth = new DateTime(1988, 7, 15, 0, 0, 0, DateTimeKind.Utc),
                SecurityStamp = Guid.NewGuid().ToString(),
            };
            regularUser2.PasswordHash = passwordHasher.HashPassword(regularUser2, "User@1234");

            var regularUser3 = new User
            {
                Id = -303,
                FirstName = "Dario",
                LastName = "Šimić",
                UserName = "user3@stonecarve.com",
                NormalizedUserName = "USER3@STONECARVE.COM",
                Email = "user3@stonecarve.com",
                NormalizedEmail = "USER3@STONECARVE.COM",
                EmailConfirmed = true,
                IsActive = true,
                CreatedAt = new DateTime(2024, 1, 18, 0, 0, 0, DateTimeKind.Utc),
                DateOfBirth = new DateTime(1995, 11, 3, 0, 0, 0, DateTimeKind.Utc),
                SecurityStamp = Guid.NewGuid().ToString(),
            };
            regularUser3.PasswordHash = passwordHasher.HashPassword(regularUser3, "User@1234");

            builder.Entity<User>().HasData(
                user1, originalAdmin,
                admin1, admin2, admin3,
                employee1, employee2, employee3,
                regularUser1, regularUser2, regularUser3
            );
        }
    }
}
