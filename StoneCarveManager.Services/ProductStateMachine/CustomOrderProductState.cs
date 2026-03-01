using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Services.Database.Context;
using StoneCarveManager.Services.Database.Entities;
using MapsterMapper;

namespace StoneCarveManager.Services.ProductStateMachine
{
    /// <summary>
    /// State for custom order products.
    /// Custom orders are one-off items created from customer specifications.
    /// 
    /// BUSINESS RULES:
    /// - Custom orders are created directly from customer requests (bypass initial/draft states)
    /// - They are not available for general sale (cannot transition to "active")
    /// - They follow a simplified lifecycle with only two possible transitions
    /// 
    /// ALLOWED TRANSITIONS:
    /// - custom_order ? portfolio (showcase completed work with customer permission)
    /// - custom_order ? hidden (customer privacy, cancellation, or failed projects)
    /// 
    /// DESIGN RATIONALE:
    /// Custom orders represent unique, made-to-order products that should not enter
    /// the general catalog lifecycle. This state ensures they remain separate while
    /// still allowing appropriate post-completion actions (portfolio showcase or hiding).
    /// </summary>
    public class CustomOrderProductState : BaseProductState
    {
        public CustomOrderProductState(AppDbContext context, IMapper mapper, IServiceProvider serviceProvider)
            : base(context, mapper, serviceProvider)
        {
        }

        /// <summary>
        /// Hide custom order product from public view.
        /// Use cases:
        /// - Customer requests privacy and does not want project shown
        /// - Order was cancelled or failed
        /// - Project contains sensitive or confidential elements
        /// </summary>
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

        /// <summary>
        /// Add completed custom order to portfolio for showcasing.
        /// Use cases:
        /// - Project completed successfully and customer approves showcase
        /// - High-quality work that demonstrates company capabilities
        /// - Marketing and promotional purposes
        /// 
        /// Note: This transition should only be performed after:
        /// 1. Order is marked as "Delivered" or "Completed"
        /// 2. Customer has given explicit permission to showcase their project
        /// </summary>
        public override ProductResponse AddToPortfolio(int id)
        {
            var entity = Context.Products.Find(id);
            if (entity == null)
                throw new KeyNotFoundException($"Product with ID {id} not found");

            entity.ProductState = "portfolio";
            entity.IsInPortfolio = true;
            entity.UpdatedAt = DateTime.UtcNow;

            Context.SaveChanges();
            return Mapper.Map<ProductResponse>(entity);
        }

        /// <summary>
        /// Returns the list of allowed actions for custom order products.
        /// Only Hide and AddToPortfolio are permitted to maintain the
        /// separation between custom orders and catalog products.
        /// </summary>
        public override List<string> AllowedActions(Product? entity)
        {
            return new List<string>
            {
                nameof(Hide),
                nameof(AddToPortfolio)
            };
        }
    }
}
