using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Services.Database.Context;
using StoneCarveManager.Services.Database.Entities;
using MapsterMapper;
using Microsoft.Extensions.DependencyInjection;

namespace StoneCarveManager.Services.ProductStateMachine
{
    /// <summary>
    /// Base class for Product State Machine pattern.
    /// Each product goes through different lifecycle states with specific allowed actions.
    /// 
    /// STATE MACHINE OVERVIEW:
    /// 
    /// CATALOG PRODUCTS (Regular Lifecycle):
    /// initial → draft → active → service/portfolio → hidden
    ///                      ↓
    ///                   portfolio
    /// 
    /// CUSTOM ORDER PRODUCTS (Simplified Lifecycle):
    /// custom_order → portfolio (showcase completed work)
    ///            ↘
    ///             → hidden (privacy/cancellation)
    /// 
    /// DESIGN NOTES:
    /// - "custom_order" is a permanent state for made-to-order products
    /// - Custom orders bypass the catalog lifecycle (initial/draft/active)
    /// - This maintains architectural consistency while reflecting different business workflows
    /// </summary>
    public class BaseProductState
    {
        public AppDbContext Context { get; set; }
        public IMapper Mapper { get; set; }
        public IServiceProvider ServiceProvider { get; set; }

        public BaseProductState(AppDbContext context, IMapper mapper, IServiceProvider serviceProvider)
        {
            Context = context;
            Mapper = mapper;
            ServiceProvider = serviceProvider;
        }

        public virtual ProductResponse Insert(ProductInsertRequest request)
        {
            throw new InvalidOperationException("Insert nije dozvoljen u ovom stanju");
        }

        public virtual ProductResponse Update(int id, ProductUpdateRequest request)
        {
            throw new InvalidOperationException("Update nije dozvoljen u ovom stanju");
        }

        public virtual ProductResponse Activate(int id)
        {
            throw new InvalidOperationException("Activate nije dozvoljen u ovom stanju");
        }

        public virtual ProductResponse Hide(int id)
        {
            throw new InvalidOperationException("Hide nije dozvoljen u ovom stanju");
        }

        public virtual ProductResponse MakeService(int id)
        {
            throw new InvalidOperationException("MakeService nije dozvoljen u ovom stanju");
        }

        public virtual ProductResponse AddToPortfolio(int id)
        {
            throw new InvalidOperationException("AddToPortfolio nije dozvoljen u ovom stanju");
        }

        public virtual List<string> AllowedActions(Product? entity)
        {
            throw new InvalidOperationException("Metoda nije dozvoljena");
        }

        /// <summary>
        /// Factory method to create the appropriate state handler for a given state name.
        /// All product states (both catalog and custom order) are managed through this method
        /// to ensure consistent application of the State Machine pattern.
        /// </summary>
        /// <param name="stateName">The product state name (e.g., "draft", "active", "custom_order")</param>
        /// <returns>State handler instance</returns>
        /// <exception cref="Exception">Thrown if state name is not recognized</exception>
        public BaseProductState CreateState(string stateName)
        {
            switch (stateName)
            {
                case "initial":
                    return ServiceProvider.GetRequiredService<InitialProductState>();
                case "draft":
                    return ServiceProvider.GetRequiredService<DraftProductState>();
                case "active":
                    return ServiceProvider.GetRequiredService<ActiveProductState>();
                case "service":
                    return ServiceProvider.GetRequiredService<ServiceProductState>();
                case "portfolio":
                    return ServiceProvider.GetRequiredService<PortfolioProductState>();
                case "hidden":
                    return ServiceProvider.GetRequiredService<HiddenProductState>();
                case "custom_order":
                    return ServiceProvider.GetRequiredService<CustomOrderProductState>();
                default:
                    throw new Exception($"State not recognized: {stateName}");
            }
        }
    }
}
