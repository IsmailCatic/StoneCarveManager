using FluentValidation;
using StoneCarveManager.Model.Requests;

namespace StoneCarveManager.Model.Validators
{
    public class UpdateOrderStatusRequestValidator : AbstractValidator<UpdateOrderStatusRequest>
    {
        public UpdateOrderStatusRequestValidator()
        {
            RuleFor(x => x.NewStatus)
                .IsInEnum().WithMessage("Invalid order status.");

            When(x => x.Comment != null, () =>
                RuleFor(x => x.Comment).MaximumLength(500).WithMessage("Comment cannot exceed 500 characters."));
        }
    }
}
