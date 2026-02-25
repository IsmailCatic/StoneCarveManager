using FluentValidation;
using StoneCarveManager.Model.Requests;

namespace StoneCarveManager.Model.Validators
{
    public class CheckoutRequestValidator : AbstractValidator<CheckoutRequest>
    {
        public CheckoutRequestValidator()
        {
            When(x => x.DeliveryAddress != null, () =>
                RuleFor(x => x.DeliveryAddress).MaximumLength(500));

            When(x => x.DeliveryCity != null, () =>
                RuleFor(x => x.DeliveryCity).MaximumLength(100));

            When(x => x.DeliveryZipCode != null, () =>
                RuleFor(x => x.DeliveryZipCode).MaximumLength(20));

            When(x => x.CustomerNotes != null, () =>
                RuleFor(x => x.CustomerNotes).MaximumLength(2000));

            RuleFor(x => x.PaymentMethod)
                .NotEmpty().WithMessage("Payment method is required.")
                .MaximumLength(50);
        }
    }
}
