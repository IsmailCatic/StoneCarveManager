using FluentValidation;
using StoneCarveManager.Model.Requests;

namespace StoneCarveManager.Model.Validators
{
    public class CustomOrderInsertRequestValidator : AbstractValidator<CustomOrderInsertRequest>
    {
        public CustomOrderInsertRequestValidator()
        {
            RuleFor(x => x.CategoryId)
                .GreaterThan(0).WithMessage("Category is required.");

            RuleFor(x => x.MaterialId)
                .GreaterThan(0).WithMessage("Material is required.");

            RuleFor(x => x.Dimensions)
                .NotEmpty().WithMessage("Dimensions are required.")
                .MaximumLength(200).WithMessage("Dimensions cannot exceed 200 characters.");

            RuleFor(x => x.Description)
                .NotEmpty().WithMessage("Description is required.")
                .Length(10, 4000).WithMessage("Description must be between 10 and 4000 characters.");

            When(x => x.CustomerNotes != null, () =>
                RuleFor(x => x.CustomerNotes).MaximumLength(2000).WithMessage("Customer notes cannot exceed 2000 characters."));

            When(x => x.EstimatedPrice.HasValue, () =>
                RuleFor(x => x.EstimatedPrice).GreaterThanOrEqualTo(0).WithMessage("Estimated price cannot be negative."));

            When(x => x.DeliveryAddress != null, () =>
                RuleFor(x => x.DeliveryAddress).MaximumLength(500));

            When(x => x.DeliveryCity != null, () =>
                RuleFor(x => x.DeliveryCity).MaximumLength(100));

            When(x => x.DeliveryZipCode != null, () =>
                RuleFor(x => x.DeliveryZipCode).MaximumLength(20));
        }
    }
}
