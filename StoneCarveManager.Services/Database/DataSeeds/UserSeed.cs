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
                //DateOfBirth = new DateOnly(2000, 5, 12),
                //CityId = -999,
                //CountryId = -999,
                //GenderId = -999
            };

            user1.PasswordHash = passwordHasher.HashPassword(user1, "Ismail$ifr4");


            builder.Entity<User>().HasData(user1);
        }

    }
}
