using FluentValidation;
using StoneCarveManager.Model.Requests;

namespace StoneCarveManager.Model.Validators
{
    public class ConfirmPaymentRequestValidator : AbstractValidator<ConfirmPaymentRequest>
    {
        public ConfirmPaymentRequestValidator()
        {
            RuleFor(x => x.PaymentIntentId)
                .NotEmpty().WithMessage("Payment intent ID is required.");

            RuleFor(x => x.OrderId)
                .NotEqual(0).WithMessage("Order ID is required.");
        }
    }
}
