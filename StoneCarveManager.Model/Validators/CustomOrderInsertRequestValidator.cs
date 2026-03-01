using FluentValidation;
using StoneCarveManager.Model.Requests;

namespace StoneCarveManager.Model.Validators
{
    public class CustomOrderInsertRequestValidator : AbstractValidator<CustomOrderInsertRequest>
    {
        public CustomOrderInsertRequestValidator()
        {
            When(x => x.CategoryId.HasValue, () =>
                RuleFor(x => x.CategoryId).GreaterThan(0).WithMessage("Category ID must be valid."));

            When(x => x.MaterialId.HasValue, () =>
                RuleFor(x => x.MaterialId).GreaterThan(0).WithMessage("Material ID must be valid."));

            When(x => !string.IsNullOrEmpty(x.Dimensions), () =>
                RuleFor(x => x.Dimensions).MaximumLength(200).WithMessage("Dimensions cannot exceed 200 characters."));

            RuleFor(x => x.DeliveryAddress)
                .NotEmpty().WithMessage("Delivery address is required.")
                .MaximumLength(500);

            RuleFor(x => x.DeliveryCity)
                .NotEmpty().WithMessage("City is required.")
                .MaximumLength(100);

            RuleFor(x => x.DeliveryZipCode)
                .NotEmpty().WithMessage("Postal code is required.")
                .MaximumLength(20);

            RuleFor(x => x.Description)
                .NotEmpty().WithMessage("Description is required.")
                .Length(10, 4000).WithMessage("Description must be between 10 and 4000 characters.");

            When(x => x.CustomerNotes != null, () =>
                RuleFor(x => x.CustomerNotes).MaximumLength(2000).WithMessage("Customer notes cannot exceed 2000 characters."));

            When(x => x.EstimatedPrice.HasValue, () =>
                RuleFor(x => x.EstimatedPrice).GreaterThanOrEqualTo(0).WithMessage("Estimated price cannot be negative."));
        }
    }
}
