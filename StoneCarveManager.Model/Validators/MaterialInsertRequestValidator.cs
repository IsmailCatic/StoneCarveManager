using FluentValidation;
using StoneCarveManager.Model.Requests;

namespace StoneCarveManager.Model.Validators
{
    public class MaterialInsertRequestValidator : AbstractValidator<MaterialInsertRequest>
    {
        public MaterialInsertRequestValidator()
        {
            RuleFor(x => x.Name)
                .NotEmpty().WithMessage("Material name is required.")
                .Length(2, 100).WithMessage("Material name must be between 2 and 100 characters.");

            RuleFor(x => x.Description)
                .NotEmpty().WithMessage("Description is required.")
                .MaximumLength(500).WithMessage("Description cannot exceed 500 characters.");

            When(x => x.ImageUrl != null, () =>
                RuleFor(x => x.ImageUrl).MaximumLength(500));

            RuleFor(x => x.PricePerUnit)
                .GreaterThan(0).WithMessage("Price per unit must be greater than 0.");

            RuleFor(x => x.Unit)
                .NotEmpty().WithMessage("Unit is required.")
                .MaximumLength(20).WithMessage("Unit cannot exceed 20 characters.");

            RuleFor(x => x.QuantityInStock)
                .GreaterThanOrEqualTo(0).WithMessage("Quantity in stock cannot be negative.");
        }
    }
}
