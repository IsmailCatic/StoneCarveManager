using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Services.Database.Context;
using StoneCarveManager.Services.Database.Entities;
using MapsterMapper;

namespace StoneCarveManager.Services.ProductStateMachine
{
    public class ServiceProductState : BaseProductState
    {
        public ServiceProductState(AppDbContext context, IMapper mapper, IServiceProvider serviceProvider)
            : base(context, mapper, serviceProvider)
        {
        }

        public override ProductResponse Update(int id, ProductUpdateRequest request)
        {
            var entity = Context.Products.Find(id);
            if (entity == null)
                throw new KeyNotFoundException($"Product with ID {id} not found");

            Mapper.Map(request, entity);
            entity.UpdatedAt = DateTime.UtcNow;

            Context.SaveChanges();

            return Mapper.Map<ProductResponse>(entity);
        }

        public override ProductResponse Hide(int id)
        {
            var entity = Context.Products.Find(id);
            if (entity == null)
                throw new KeyNotFoundException($"Product with ID {id} not found");

            entity.ProductState = "hidden";
            entity.UpdatedAt = DateTime.UtcNow;

            Context.SaveChanges();

            return Mapper.Map<ProductResponse>(entity);
        }

        public override List<string> AllowedActions(Product? entity)
        {
            return new List<string>
            {
                nameof(Update),
                nameof(Hide)
            };
        }
    }
}
