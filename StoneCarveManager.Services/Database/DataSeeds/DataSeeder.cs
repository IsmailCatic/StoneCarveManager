using Microsoft.EntityFrameworkCore;
using StoneCarveManager.Services.Database.Context;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.Database.DataSeeds
{
    internal static class DataSeeder
    {

        public static void SeedDefaultConfigurationData(ModelBuilder builder)
        {
            UserSeed.Seed(builder);
            RoleSeed.Seed(builder);
            CategorySeed.Seed(builder);
            ProductSeed.Seed(builder);
            MaterialSeed.Seed(builder);



        }


    }

}
