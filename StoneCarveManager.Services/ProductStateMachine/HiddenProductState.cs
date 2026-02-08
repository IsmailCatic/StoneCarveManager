using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Services.Database.Context;
using StoneCarveManager.Services.Database.Entities;
using MapsterMapper;

namespace StoneCarveManager.Services.ProductStateMachine
{
    public class HiddenProductState : BaseProductState
    {
        public HiddenProductState(AppDbContext context, IMapper mapper, IServiceProvider serviceProvider)
            : base(context, mapper, serviceProvider)
        {
        }

        public override ProductResponse Activate(int id)
        {
            var entity = Context.Products.Find(id);
            if (entity == null)
                throw new KeyNotFoundException($"Product with ID {id} not found");

            entity.ProductState = "active";
            entity.IsActive = true;
            entity.UpdatedAt = DateTime.UtcNow;

            Context.SaveChanges();

            return Mapper.Map<ProductResponse>(entity);
        }

        public override List<string> AllowedActions(Product? entity)
        {
            return new List<string>
            {
                nameof(Activate)
            };
        }
    }
}
