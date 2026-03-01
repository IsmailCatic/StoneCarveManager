using FluentValidation;
using StoneCarveManager.Model.Requests;

namespace StoneCarveManager.Model.Validators
{
    public class ProductInsertRequestValidator : AbstractValidator<ProductInsertRequest>
    {
        public ProductInsertRequestValidator()
        {
            RuleFor(x => x.Name)
                .NotEmpty().WithMessage("Product name is required.")
                .Length(2, 200).WithMessage("Product name must be between 2 and 200 characters.");

            RuleFor(x => x.Description)
                .NotEmpty().WithMessage("Description is required.")
                .MaximumLength(2000).WithMessage("Description cannot exceed 2000 characters.");

            RuleFor(x => x.Price)
                .GreaterThan(0).WithMessage("Price must be greater than 0.");

            RuleFor(x => x.StockQuantity)
                .GreaterThanOrEqualTo(0).WithMessage("Stock quantity cannot be negative.");

            When(x => x.Dimensions != null, () =>
                RuleFor(x => x.Dimensions).MaximumLength(100));

            When(x => x.Weight.HasValue, () =>
                RuleFor(x => x.Weight).GreaterThanOrEqualTo(0).WithMessage("Weight cannot be negative."));

            RuleFor(x => x.EstimatedDays)
                .InclusiveBetween(1, 365).WithMessage("Estimated days must be between 1 and 365.");

            // CategoryId is now optional (nullable)
            When(x => x.CategoryId.HasValue, () =>
                RuleFor(x => x.CategoryId).NotEqual(0).WithMessage("Category ID must be valid when provided."));

            // MaterialId is now optional (nullable)
            When(x => x.MaterialId.HasValue, () =>
                RuleFor(x => x.MaterialId).NotEqual(0).WithMessage("Material ID must be valid when provided."));
        }
    }
}
