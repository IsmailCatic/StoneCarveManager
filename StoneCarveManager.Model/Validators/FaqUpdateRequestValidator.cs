using FluentValidation;
using StoneCarveManager.Model.Requests;

namespace StoneCarveManager.Model.Validators
{
    public class FaqUpdateRequestValidator : AbstractValidator<FaqUpdateRequest>
    {
        public FaqUpdateRequestValidator()
        {
            When(x => x.Question != null, () =>
                RuleFor(x => x.Question).Length(5, 500).WithMessage("Question must be between 5 and 500 characters."));

            When(x => x.Answer != null, () =>
                RuleFor(x => x.Answer).Length(5, 4000).WithMessage("Answer must be between 5 and 4000 characters."));

            When(x => x.Category != null, () =>
                RuleFor(x => x.Category).MaximumLength(100).WithMessage("Category cannot exceed 100 characters."));

            When(x => x.DisplayOrder.HasValue, () =>
                RuleFor(x => x.DisplayOrder).GreaterThanOrEqualTo(0).WithMessage("Display order cannot be negative."));
        }
    }
}
