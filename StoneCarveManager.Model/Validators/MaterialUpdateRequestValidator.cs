using FluentValidation;
using StoneCarveManager.Model.Requests;

namespace StoneCarveManager.Model.Validators
{
    public class MaterialUpdateRequestValidator : AbstractValidator<MaterialUpdateRequest>
    {
        public MaterialUpdateRequestValidator()
        {
            When(x => x.Name != null, () =>
                RuleFor(x => x.Name).Length(2, 100).WithMessage("Material name must be between 2 and 100 characters."));

            When(x => x.Description != null, () =>
                RuleFor(x => x.Description).MaximumLength(500).WithMessage("Description cannot exceed 500 characters."));

            When(x => x.ImageUrl != null, () =>
                RuleFor(x => x.ImageUrl).MaximumLength(500));

            When(x => x.PricePerUnit.HasValue, () =>
                RuleFor(x => x.PricePerUnit).GreaterThan(0).WithMessage("Price per unit must be greater than 0."));

            When(x => x.Unit != null, () =>
                RuleFor(x => x.Unit).MaximumLength(20).WithMessage("Unit cannot exceed 20 characters."));

            When(x => x.QuantityInStock.HasValue, () =>
                RuleFor(x => x.QuantityInStock).GreaterThanOrEqualTo(0).WithMessage("Quantity in stock cannot be negative."));
        }
    }
}
