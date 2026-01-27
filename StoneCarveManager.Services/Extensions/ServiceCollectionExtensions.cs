using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using StoneCarveManager.Services.Database.Context;
using StoneCarveManager.Services.IServices;
using StoneCarveManager.Services.Services;

namespace StoneCarveManager.Services.Extensions
{
    public static class ServiceCollectionExtensions
    {
        public static void RegisterServiceLayerDependencies(this IServiceCollection services, IConfiguration configuration)
        {
            services.AddDbContext<AppDbContext>(options =>
            {
                options.UseSqlServer(configuration.GetConnectionString("MainDB"));
            });

            // Authentication & User services
            services.AddScoped<IAuthService, AuthService>();
            services.AddScoped<IUserService, UserService>();

            // CRUD services
            services.AddScoped<ICategoryService, CategoryService>();
            services.AddScoped<IMaterialService, MaterialService>();
            services.AddScoped<IProductService, ProductService>();
            services.AddScoped<IBlogPostService, BlogPostService>();
            services.AddScoped<IProductImageService, ProductImageService>();
            services.AddScoped<IProductReviewService, ProductReviewService>();
            services.AddScoped<IFileService, AzureBlobFileService>();

            // Register Role service
            services.AddScoped<IRoleService, RoleService>();

            services.AddScoped<IOrderService, OrderService>();
        }
    }
}
