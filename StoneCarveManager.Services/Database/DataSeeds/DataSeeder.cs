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
            // ── Identity ──────────────────────────────────────────────────────────
            UserSeed.Seed(builder);
            RoleSeed.Seed(builder);

            // ── Catalogue ─────────────────────────────────────────────────────────
            CategorySeed.Seed(builder);
            MaterialSeed.Seed(builder);
            ProductSeed.Seed(builder);
            ProductImageSeed.Seed(builder);

            // ── Blog ──────────────────────────────────────────────────────────────
            BlogCategorySeed.Seed(builder);
            BlogPostSeed.Seed(builder);

            // ── Support ───────────────────────────────────────────────────────────
            FaqSeed.Seed(builder);

            // ── Commerce (order matters: Cart → Order → Payment → Reviews) ────────
            //CartSeed.Seed(builder);
            OrderSeed.Seed(builder);
            PaymentSeed.Seed(builder);
            ProductReviewSeed.Seed(builder);
            FavoriteProductSeed.Seed(builder);
        }


    }

}
