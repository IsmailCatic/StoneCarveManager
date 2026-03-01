using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using StoneCarveManager.Services.Database.Context;
using StoneCarveManager.Services.IServices;
using StoneCarveManager.Services.Services;
using StoneCarveManager.Services.ProductStateMachine;

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

            // Current User service (must be scoped to access HttpContext)
            services.AddScoped<ICurrentUserService, CurrentUserService>();

            // Authentication & User services
            services.AddScoped<IAuthService, AuthService>();
            services.AddScoped<IUserService, UserService>();

            // CRUD services
            services.AddScoped<ICategoryService, CategoryService>();
            services.AddScoped<IMaterialService, MaterialService>();
            services.AddScoped<IProductService, ProductService>();
            services.AddScoped<IBlogPostService, BlogPostService>();
            services.AddScoped<IBlogCategoryService, BlogCategoryService>();
            services.AddScoped<IProductImageService, ProductImageService>();
            services.AddScoped<IProductReviewService, ProductReviewService>();
            services.AddScoped<IFileService, AzureBlobFileService>();

            // Register Role service
            services.AddScoped<IRoleService, RoleService>();

            services.AddScoped<IOrderService, OrderService>();
            
            // Register Cart service
            services.AddScoped<ICartService, CartService>();
            
            // Register Payment service
            services.AddScoped<IPaymentService, PaymentService>();
            
            // Register Checkout service
            services.AddScoped<ICheckoutService, CheckoutService>();
            
            // Register Favorite service
            services.AddScoped<IFavoriteService, FavoriteService>();

            // Register FAQ service
            services.AddScoped<IFaqService, FaqService>();

            // Register consolidated Analytics service (replaces BusinessAnalyticsService)
            services.AddScoped<IAnalyticsService, AnalyticsService>();

            // Register Product State Machine
            services.AddTransient<BaseProductState>();
            services.AddTransient<InitialProductState>();
            services.AddTransient<DraftProductState>();
            services.AddTransient<ActiveProductState>();
            services.AddTransient<ServiceProductState>();
            services.AddTransient<PortfolioProductState>();
            services.AddTransient<HiddenProductState>();
            services.AddTransient<CustomOrderProductState>();
        }
    }
}
