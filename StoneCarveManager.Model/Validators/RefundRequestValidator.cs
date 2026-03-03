using FluentValidation;
using StoneCarveManager.Model.Requests;

namespace StoneCarveManager.Model.Validators
{
    public class RefundRequestValidator : AbstractValidator<RefundRequest>
    {
        public RefundRequestValidator()
        {
            RuleFor(x => x.PaymentIntentId)
                .NotEmpty().WithMessage("Payment intent ID is required.");

            RuleFor(x => x.OrderId)
                .NotEqual(0).WithMessage("Order ID is required.");

            When(x => x.Amount.HasValue, () =>
                RuleFor(x => x.Amount).GreaterThan(0).WithMessage("Refund amount must be greater than 0."));

            When(x => x.Reason != null, () =>
                RuleFor(x => x.Reason).MaximumLength(500));
        }
    }
}
