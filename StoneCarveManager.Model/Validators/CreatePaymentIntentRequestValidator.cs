using FluentValidation;
using StoneCarveManager.Model.Requests;

namespace StoneCarveManager.Model.Validators
{
    public class CreatePaymentIntentRequestValidator : AbstractValidator<CreatePaymentIntentRequest>
    {
        public CreatePaymentIntentRequestValidator()
        {
            RuleFor(x => x.OrderId)
                .GreaterThan(0).WithMessage("Order ID is required.");

            RuleFor(x => x.PaymentMethod)
                .NotEmpty().WithMessage("Payment method is required.")
                .MaximumLength(50);

            When(x => x.CustomerEmail != null, () =>
                RuleFor(x => x.CustomerEmail).EmailAddress().WithMessage("Invalid email format."));

            When(x => x.CustomerName != null, () =>
                RuleFor(x => x.CustomerName).MaximumLength(100));
        }
    }
}
