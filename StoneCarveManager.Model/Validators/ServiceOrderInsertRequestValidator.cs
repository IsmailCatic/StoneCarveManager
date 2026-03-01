using FluentValidation;
using StoneCarveManager.Model.Requests;

namespace StoneCarveManager.Model.Validators
{
    public class ServiceOrderInsertRequestValidator : AbstractValidator<ServiceOrderInsertRequest>
    {
        public ServiceOrderInsertRequestValidator()
        {
            RuleFor(x => x.ServiceProductId)
                .GreaterThan(0).WithMessage("A valid service product must be selected.");

            RuleFor(x => x.Requirements)
                .NotEmpty().WithMessage("Requirements are required.")
                .Length(10, 4000).WithMessage("Requirements must be between 10 and 4000 characters.");

            When(x => x.Dimensions != null, () =>
                RuleFor(x => x.Dimensions).MaximumLength(200).WithMessage("Dimensions cannot exceed 200 characters."));

            When(x => x.CustomerNotes != null, () =>
                RuleFor(x => x.CustomerNotes).MaximumLength(2000).WithMessage("Customer notes cannot exceed 2000 characters."));

            When(x => x.DeliveryAddress != null, () =>
                RuleFor(x => x.DeliveryAddress).MaximumLength(500));

            When(x => x.DeliveryCity != null, () =>
                RuleFor(x => x.DeliveryCity).MaximumLength(100));

            When(x => x.DeliveryZipCode != null, () =>
                RuleFor(x => x.DeliveryZipCode).MaximumLength(20));
        }
    }
}
