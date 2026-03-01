using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Services.Database.Context;
using StoneCarveManager.Services.Database.Entities;
using MapsterMapper;

namespace StoneCarveManager.Services.ProductStateMachine
{
    public class InitialProductState : BaseProductState
    {
        public InitialProductState(AppDbContext context, IMapper mapper, IServiceProvider serviceProvider)
            : base(context, mapper, serviceProvider)
        {
        }

        public override ProductResponse Insert(ProductInsertRequest request)
        {
            var entity = Mapper.Map<Product>(request);
            entity.ProductState = "draft";
            entity.CreatedAt = DateTime.UtcNow;

            Context.Products.Add(entity);
            Context.SaveChanges();

            return Mapper.Map<ProductResponse>(entity);
        }

        public override List<string> AllowedActions(Product? entity)
        {
            return new List<string> { nameof(Insert) };
        }
    }
}
