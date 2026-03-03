using FluentValidation;
using StoneCarveManager.Model.Requests;

namespace StoneCarveManager.Model.Validators
{
    public class ServiceOrderInsertRequestValidator : AbstractValidator<ServiceOrderInsertRequest>
    {
        public ServiceOrderInsertRequestValidator()
        {
            RuleFor(x => x.ServiceProductId)
                .NotEqual(0).WithMessage("A valid service product must be selected.");

            RuleFor(x => x.Requirements)
                .NotEmpty().WithMessage("Requirements are required.")
                .Length(10, 4000).WithMessage("Requirements must be between 10 and 4000 characters.");

            When(x => x.Dimensions != null, () =>
                RuleFor(x => x.Dimensions).MaximumLength(200).WithMessage("Dimensions cannot exceed 200 characters."));

            When(x => x.CustomerNotes != null, () =>
                RuleFor(x => x.CustomerNotes).MaximumLength(2000).WithMessage("Customer notes cannot exceed 2000 characters."));

            RuleFor(x => x.DeliveryAddress)
                .NotEmpty().WithMessage("Delivery address is required.")
                .MaximumLength(500);

            RuleFor(x => x.DeliveryCity)
                .NotEmpty().WithMessage("City is required.")
                .MaximumLength(100);

            RuleFor(x => x.DeliveryZipCode)
                .NotEmpty().WithMessage("Postal code is required.")
                .MaximumLength(20);
        }
    }
}
