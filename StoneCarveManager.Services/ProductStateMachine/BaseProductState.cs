using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Services.Database.Context;
using StoneCarveManager.Services.Database.Entities;
using MapsterMapper;
using Microsoft.Extensions.DependencyInjection;

namespace StoneCarveManager.Services.ProductStateMachine
{
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
                default:
                    throw new Exception($"State not recognized: {stateName}");
            }
        }
    }
}
